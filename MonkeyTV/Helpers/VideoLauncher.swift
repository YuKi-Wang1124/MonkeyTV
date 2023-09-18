//
//  VideoLauncher.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/14.
//

import UIKit
import youtube_ios_player_helper

class VideoLauncher: NSObject {
    var ytVideoPlayerView = YTPlayerView()
    var videoId = ""
    private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30)
    private let pauseSymbolConfig = UIImage.SymbolConfiguration(pointSize: 50)
    private var buttonsView = UIView()
    private var isDanMuDisplayed = false
    private var videoIsPlaying = true
    private var playerIsShrink = false
    private var videoDuration = 0
    private var bulletChats = [BulletChat]()
    private lazy var changeOrientationButton = {
        return createPlayerBtn(image: UIImage.systemAsset(.enlarge, configuration: symbolConfig)!)
    }()
    private lazy var showDanMuButton = {
        return createPlayerBtn(image: UIImage.systemAsset(.square, configuration: symbolConfig)!)
    }()
    private lazy var addDanMuButton = {
        return createPlayerBtn(image: UIImage.systemAsset(.submitDanMu, configuration: symbolConfig)!)
    }()
    private lazy var showChatRoomButton = {
      return createPlayerBtn(image: UIImage.systemAsset(.chatroom, configuration: symbolConfig)!)
    }()
    private lazy var pauseButton = {
        return createPlayerBtn(image: UIImage.systemAsset(.pause, configuration: pauseSymbolConfig)!)
    }()
    private lazy var danMuTextField = {
        return UITextField.createTextField(text: "輸入彈幕")
    }()
    private lazy var submitDanMuButton = {
        let button = UIButton()
        button.setTitle("送出彈幕", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var videoSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    private var danmuView: DanMuView = DanMuView()
    private var timer: Timer?
    // MARK: - init
    override init() {
        super.init()
        ytVideoPlayerView.backgroundColor = .black
        setBtnsAddtarget()
        ytVideoPlayerView.delegate = self
    }
    // MARK: - getDanMuData
    private func getDanMuData() {
        FirestoreManageer.bulletChatCollection.whereField("videoId", isEqualTo: videoId).getDocuments { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                        let decodedObject = try JSONDecoder().decode(BulletChatData.self, from: jsonData)
                        self.bulletChats.append(decodedObject.bulletChat)
                        print(self.bulletChats)
                    } catch {
                        print("\(error)")
                    }
                }
            }
        }
    }
    // MARK: - setDanMu
    private func setDanMu() {
        danmuView.isHidden = true
        danmuView.minSpeed = 1
        danmuView.maxSpeed = 2
        danmuView.gap = 20
        danmuView.lineHeight = 30
        danmuView.start()
        timer = Timer.scheduledTimer(timeInterval: 0.4,
                                     target: self, selector: #selector(addDanMuText),
                                     userInfo: nil, repeats: false)
    }
    private func addDanMu() {
        danmuView.danmuQueue.append(("text", false))
    }
    @objc func addDanMuText() {
        let interval = CGFloat.random(in: 0.3...1.0)
        Timer.scheduledTimer(timeInterval: interval,
                             target: self, selector: #selector(addDanMuText),
                             userInfo: nil, repeats: false)
    }
    // MARK: - showVideoPlayer
    func showVideoPlayer() {
        getDanMuData()
        setDanMu()
        if let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).last {
            let view = UIView(frame: keyWindow.frame)
            view.backgroundColor = .white
            keyWindow.addSubview(view)
            let safeAreaInsets = keyWindow.safeAreaInsets
            let topInset = safeAreaInsets.top
            let bottomInset = safeAreaInsets.bottom
            let notchHeight = max(topInset, bottomInset)
            addYTView(view: view)
            // TODO: change Orientation layout
            setYTViewLayout(view: view, notchHeight: notchHeight)
            //            setLandscapeYTViewLayout(view: view)
            addBtnsOnBtnView()
            setBtnsAutoLayout()
            let playerVars: [AnyHashable: Any] = [
                "frameborder": 0,
                "width": 100,
                "loop": 0,
                "playsigline": 1,
                "controls": 0,
                //                "autohide": 1,
                "showinfo": 0,
                "fs": 0,
                //                "rel": 0,
                "autoplay": 1
            ]
            ytVideoPlayerView.load(withVideoId: videoId, playerVars: playerVars)
            UIView.animate(withDuration: 0.5, delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                view.frame = keyWindow.frame
            }, completion: { (completedAnimation) in
                // may be do something later
            })
        }
    }
    // MARK: - Buttons AddTaget
    private func setBtnsAddtarget() {
        showDanMuButton.addTarget(self, action: #selector(tapBulletBtn(sender:)),
                                  for: .touchUpInside)
        addDanMuButton.addTarget(self, action: #selector(tapSubmitDanMuButton(sender:)),
                                 for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseVideo(sender:)),for: .touchUpInside)
        changeOrientationButton.addTarget(self,
                                          action: #selector(changeOrientation(sender:)),
                                          for: .touchUpInside)
        submitDanMuButton.addTarget(self, action: #selector(tapSubmitDanMuButton(sender:)),
                                    for: .touchUpInside)
        videoSlider.addTarget(self, action: #selector(handleSliderChange(sender:)),
                              for: .valueChanged)
        showChatRoomButton.addTarget(self, action: #selector(showChatRoom(sender:)),
                              for: .touchUpInside)
    }
    @objc func showChatRoom(sender: UIButton) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            let chatroomVC = ChatroomViewController()
            if let sheet = chatroomVC.sheetPresentationController {
                sheet.prefersGrabberVisible = true
                sheet.detents = [.medium(), .large()]
                sheet.largestUndimmedDetentIdentifier = .large
                keyWindow.rootViewController?.present(chatroomVC, animated: true)
            }
        }
    }
    // MARK: - Buttons objc functions
    @objc func handleSliderChange(sender: UISlider) {
        let desiredTime = sender.value
        ytVideoPlayerView.seek(toSeconds: desiredTime, allowSeekAhead: true)
    }
    @objc func tapSubmitDanMuButton(sender: UIButton) {
        if let text = danMuTextField.text, text.isEmpty == false {
            let id = FirestoreManageer.bulletChatCollection.document().documentID
            let data: [String: Any] = ["bulletChat":
                                        ["chatId": UUID().uuidString,
                                         "content": text,
                                         "contentType": 0,
                                         "popTime": videoSlider.value,
                                         // TODO: userid
                                         "userId": "匿名"] as [String: Any],
                                       "videoId": videoId,
                                       "id": id]
            FirestoreManageer.bulletChatCollection.document(id).setData(data) { error in
                if error != nil {
                    print("Error adding document: (error)")
                } else {
                    self.danMuTextField.text = ""
                }
            }
        }
    }
    @objc func changeOrientation(sender: UIButton) {
        if playerIsShrink == false {
            sender.setImage(UIImage.systemAsset(.shrink, configuration: symbolConfig), for: .normal)
        } else {
            sender.setImage(UIImage.systemAsset(.enlarge, configuration: symbolConfig), for: .normal)
        }
        playerIsShrink.toggle()
    }
    @objc func pauseVideo(sender: UIButton) {
        danmuView.isPause = !danmuView.isPause
        if videoIsPlaying {
            sender.setImage(UIImage.systemAsset(.play, configuration: pauseSymbolConfig), for: .normal)
            ytVideoPlayerView.pauseVideo()
        } else {
            sender.setImage(UIImage.systemAsset(.pause, configuration: pauseSymbolConfig), for: .normal)
            ytVideoPlayerView.playVideo()
        }
        videoIsPlaying.toggle()
    }
    @objc func tapBulletBtn(sender: UIButton) {
        if !isDanMuDisplayed {
            sender.setImage(UIImage.systemAsset(.checkmarkSquare, configuration: symbolConfig), for: .normal)
            danmuView.isHidden = false
        } else {
            sender.setImage(UIImage.systemAsset(.square, configuration: symbolConfig), for: .normal)
            danmuView.isHidden = true
        }
        isDanMuDisplayed.toggle()
    }
}
// MARK: - YTPlayerViewDelegate
extension VideoLauncher: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        //        ytVideoPlayerView.playVideo()
        getVideoDuratiion()
        print("video is ready")
    }
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .playing:
            print("Video is playing")
        case .paused:
            print("Video is paused")
        case .ended:
            print("Video playback ended")
        default:
            break
        }
    }
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
    }
    //    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
    //    }
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        if self.videoDuration != 0 {
            self.videoSlider.maximumValue = Float(self.videoDuration)
            videoSlider.value = playTime
        }
    }
    func getVideoDuratiion() {
        ytVideoPlayerView.duration { (duration, error) in
            if let error = error {
                print("無法取得影片總時間：\(error.localizedDescription)")
            } else {
                self.videoDuration = Int(duration)
            }
        }
    }
}

// MARK: - Layout
extension VideoLauncher {
    private func addBtnsOnBtnView() {
        buttonsView.addSubview(showDanMuButton)
        buttonsView.addSubview(addDanMuButton)
        buttonsView.addSubview(pauseButton)
        buttonsView.addSubview(changeOrientationButton)
        buttonsView.addSubview(videoSlider)
    }
    private func setBtnsAutoLayout() {
        NSLayoutConstraint.activate([
            changeOrientationButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -130),
            changeOrientationButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -16),
            changeOrientationButton.widthAnchor.constraint(equalToConstant: 30),
            changeOrientationButton.heightAnchor.constraint(equalToConstant: 30),
            showDanMuButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -160),
            showDanMuButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -16),
            showDanMuButton.widthAnchor.constraint(equalToConstant: 30),
            showDanMuButton.heightAnchor.constraint(equalToConstant: 30),
            addDanMuButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -200),
            addDanMuButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -16),
            addDanMuButton.widthAnchor.constraint(equalToConstant: 30),
            addDanMuButton.heightAnchor.constraint(equalToConstant: 30),
            pauseButton.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor),
            pauseButton.centerYAnchor.constraint(equalTo: buttonsView.centerYAnchor),
            pauseButton.widthAnchor.constraint(equalToConstant: 50),
            pauseButton.heightAnchor.constraint(equalToConstant: 50),
            videoSlider.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor),
            videoSlider.centerYAnchor.constraint(equalTo: buttonsView.centerYAnchor, constant: 50),
            videoSlider.widthAnchor.constraint(equalTo: buttonsView.widthAnchor, constant: -30),
            videoSlider.heightAnchor.constraint(equalToConstant: 10),
            
        ])
    }
    private func addYTView(view: UIView) {
        buttonsView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.addSubview(ytVideoPlayerView)
        view.addSubview(buttonsView)
        buttonsView.addSubview(danmuView)
        view.addSubview(danMuTextField)
        view.addSubview(submitDanMuButton)
        view.addSubview(showChatRoomButton)
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        ytVideoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        danmuView.translatesAutoresizingMaskIntoConstraints = false
    }
    private func setYTViewLayout(view: UIView, notchHeight: CGFloat) {
        NSLayoutConstraint.activate([
            submitDanMuButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitDanMuButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            submitDanMuButton.widthAnchor.constraint(equalToConstant: 150),
            submitDanMuButton.heightAnchor.constraint(equalToConstant: 50),
            danMuTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            danMuTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            danMuTextField.widthAnchor.constraint(equalToConstant: 300),
            danMuTextField.heightAnchor.constraint(equalToConstant: 50),
            ytVideoPlayerView.topAnchor.constraint(equalTo: view.topAnchor, constant: notchHeight),
            ytVideoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ytVideoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ytVideoPlayerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ytVideoPlayerView.heightAnchor.constraint(equalTo: ytVideoPlayerView.widthAnchor, multiplier: 9 / 16),
            buttonsView.leadingAnchor.constraint(equalTo: ytVideoPlayerView.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: ytVideoPlayerView.trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: ytVideoPlayerView.topAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: ytVideoPlayerView.bottomAnchor),
            danmuView.leadingAnchor.constraint(equalTo: ytVideoPlayerView.leadingAnchor),
            danmuView.trailingAnchor.constraint(equalTo: ytVideoPlayerView.trailingAnchor),
            danmuView.topAnchor.constraint(equalTo: ytVideoPlayerView.topAnchor),
            danmuView.heightAnchor.constraint(equalTo: ytVideoPlayerView.heightAnchor, multiplier: 5 / 10),
            showChatRoomButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showChatRoomButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 150),
            showChatRoomButton.widthAnchor.constraint(equalToConstant: 30),
            showChatRoomButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    private func setLandscapeYTViewLayout(view: UIView) {
        NSLayoutConstraint.activate([
            ytVideoPlayerView.topAnchor.constraint(equalTo: view.topAnchor),
            ytVideoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ytVideoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ytVideoPlayerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ytVideoPlayerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            buttonsView.leadingAnchor.constraint(equalTo: ytVideoPlayerView.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: ytVideoPlayerView.trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: ytVideoPlayerView.topAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: ytVideoPlayerView.bottomAnchor),
            danmuView.leadingAnchor.constraint(equalTo: ytVideoPlayerView.leadingAnchor),
            danmuView.trailingAnchor.constraint(equalTo: ytVideoPlayerView.trailingAnchor),
            danmuView.topAnchor.constraint(equalTo: ytVideoPlayerView.topAnchor),
            danmuView.heightAnchor.constraint(equalTo: ytVideoPlayerView.heightAnchor, multiplier: 5 / 10)
        ])
    }
    // MARK: - Create UI Object
    private func createPlayerBtn(image: UIImage) -> UIButton {
        let btn = UIButton()
        btn.setImage(image, for: .normal)
        btn.tintColor = .gray
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }
}
