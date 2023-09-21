//
//  VideoLauncher.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/14.
//

import UIKit
import youtube_ios_player_helper

class VideoLauncher: NSObject {
    
    var baseView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var videoId = ""
    static let shared = VideoLauncher()
    private var ytVideoPlayerView = {
        let view = YTPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30)
    private let smallSymbolConfig = UIImage.SymbolConfiguration(pointSize: 20)
    private var buttonsView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var isDanMuDisplayed = false
    private var danMuTextFiedIsShow = false
    private var videoIsPlaying = true
    private var playerIsShrink = false
    private var videoDuration = 0
    private var bulletChats = [BulletChat]()
    private var tableView = {
        var tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .systemMint
        //        tableView.register(CollectionTableViewCell.self,
        //                           forCellReuseIdentifier:
        //                            CollectionTableViewCell.identifier)
        //        tableView.register(VideoTableViewCell.self,
        //                           forCellReuseIdentifier:
        //                            VideoTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private lazy var changeOrientationButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.enlarge, configuration: smallSymbolConfig),
            color: .white, cornerRadius: 20)
    }()
    private lazy var showDanMuButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.square, configuration: smallSymbolConfig),
            color: .white, cornerRadius: 15)
    }()
    private lazy var showDanMuTextFieldButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.submitDanMu, configuration: smallSymbolConfig),
            color: .white, cornerRadius: 15)
    }()
    private lazy var showChatRoomButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.chatroom, configuration: smallSymbolConfig),
            color: .systemBlue, cornerRadius: 15)
    }()
    private lazy var pauseButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.pause, configuration: symbolConfig),
            color: .white, cornerRadius: 25)
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
        let thumbImage = UIImage.systemAsset(.thumbImage)
        slider.minimumValue = 0
        slider.setThumbImage(thumbImage, for: .normal)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    private var danmuView: DanMuView = {
        let view = DanMuView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var timer: Timer?
    private let rootViewController = UIViewController.getFirstViewController()
    // MARK: - init
    override init() {
        super.init()
        baseView.backgroundColor = .yellow
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(notification:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    deinit {
        timer = nil
    }
    // MARK: - Update Landscape & Portrait Layout
    @objc func deviceOrientationDidChange(notification: Notification) {
        if let userInfoData = notification.userInfo?["orientation"] as? UIDeviceOrientation {
            if userInfoData.isPortrait {
                changeOrientationButton.setImage(
                    UIImage.systemAsset(.enlarge, configuration: smallSymbolConfig), for: .normal)
            } else {
                changeOrientationButton.setImage(
                    UIImage.systemAsset(.shrink, configuration: smallSymbolConfig), for: .normal)
            }
        }
    }
    // MARK: - Show Button View
    @objc func showButtonView() {
        self.buttonsView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.changeOrientationButton.isHidden = false
        self.showDanMuButton.isHidden = false
        self.showDanMuTextFieldButton.isHidden = false
        self.pauseButton.isHidden = false
        self.videoSlider.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.changeOrientationButton.isHidden = true
            self?.showDanMuButton.isHidden = true
            self?.showDanMuTextFieldButton.isHidden = true
            self?.pauseButton.isHidden = true
            self?.videoSlider.isHidden = true
            self?.buttonsView.backgroundColor = UIColor(white: 0, alpha: 0)
        }
    }
    // MARK: - setupVideoLauncher
    private func setupVideoLauncher() {
        buttonsView.backgroundColor = UIColor(white: 0, alpha: 0.0)
        danMuTextField.isHidden = true
        submitDanMuButton.isHidden = true
        changeOrientationButton.isHidden = true
        showDanMuButton.isHidden = true
        showDanMuTextFieldButton.isHidden = true
        pauseButton.isHidden = true
        videoSlider.isHidden = true
        setBtnsAddtarget()
        setDanMu()
        ytVideoPlayerView.delegate = self
        ytVideoPlayerView.backgroundColor = .clear
        let singleFinger = UITapGestureRecognizer(target: self, action: #selector(showButtonView))
        singleFinger.numberOfTapsRequired = 1
        singleFinger.numberOfTouchesRequired = 1
        self.buttonsView.addGestureRecognizer(singleFinger)
    }
    // MARK: - getDanMuData
    private func getDanMuData() {
        FirestoreManageer.bulletChatCollection.whereField(
            "videoId", isEqualTo: videoId).getDocuments { querySnapshot, error in
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                            let decodedObject = try JSONDecoder().decode(BulletChatData.self, from: jsonData)
                            self.bulletChats.append(decodedObject.bulletChat)
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
    @objc func addDanMuText() {
        let interval = CGFloat.random(in: 0.3...1.0)
        Timer.scheduledTimer(timeInterval: interval,
                             target: self, selector: #selector(addDanMuText),
                             userInfo: nil, repeats: false)
    }
    // MARK: - showDanMuTextField
    @objc func showDanMuTextField(sender: UIButton) {
        if danMuTextFiedIsShow == false {
            danMuTextField.isHidden = false
            submitDanMuButton.isHidden = false
        } else {
            danMuTextField.isHidden = true
            submitDanMuButton.isHidden = true
        }
        danMuTextFiedIsShow.toggle()
    }
    // MARK: - Show Chatroom
    @objc func showChatroom(sender: UIButton) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            let chatroomVC = ChatroomViewController()
            if let sheet = chatroomVC.sheetPresentationController {
                sheet.prefersGrabberVisible = true
                sheet.detents = [.medium(), .large()]
                sheet.largestUndimmedDetentIdentifier = .large
                chatroomVC.videoId = self.videoId
                keyWindow.rootViewController?.present(chatroomVC, animated: true)
            }
        }
    }
    // MARK: - Handle Slider Change
    @objc func handleSliderChange(sender: UISlider) {
        let desiredTime = sender.value
        ytVideoPlayerView.seek(toSeconds: desiredTime, allowSeekAhead: true)
    }
    // MARK: - Submit My DanMuButton
    @objc func submitMyDanMuButton(sender: UIButton) {
        if let text = danMuTextField.text, text.isEmpty == false {
            danmuView.danmuQueue.append((text, false))
            let id = FirestoreManageer.bulletChatCollection.document().documentID
            let data: [String: Any] = ["bulletChat":
                                        ["chatId": UUID().uuidString,
                                         "content": text,
                                         "contentType": 0,
                                         "popTime": videoSlider.value + 2,
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
    // MARK: - pauseVideo
    @objc func pauseVideo(sender: UIButton) {
        danmuView.isPause = !danmuView.isPause
        if videoIsPlaying {
            sender.setImage(UIImage.systemAsset(.play, configuration: symbolConfig),
                            for: .normal)
            ytVideoPlayerView.pauseVideo()
        } else {
            sender.setImage(UIImage.systemAsset(.pause, configuration: symbolConfig),
                            for: .normal)
            ytVideoPlayerView.playVideo()
        }
        videoIsPlaying.toggle()
    }
    // MARK: - showDanMuView
    @objc func showDanMuView(sender: UIButton) {
        if !isDanMuDisplayed {
            sender.setImage(UIImage.systemAsset(.checkmarkSquare, configuration: smallSymbolConfig), for: .normal)
            danmuView.isHidden = false
        } else {
            sender.setImage(UIImage.systemAsset(.square, configuration: smallSymbolConfig), for: .normal)
            danmuView.isHidden = true
        }
        isDanMuDisplayed.toggle()
    }
    // MARK: - Buttons AddTaget
    private func setBtnsAddtarget() {
        showDanMuButton.addTarget(self, action: #selector(showDanMuView(sender:)),
                                  for: .touchUpInside)
        showDanMuTextFieldButton.addTarget(self, action: #selector(showDanMuTextField(sender:)),
                                           for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseVideo(sender:)), for: .touchUpInside)
        changeOrientationButton.addTarget(self,
                                          action: #selector(changeOrientation(sender:)),
                                          for: .touchUpInside)
        submitDanMuButton.addTarget(self, action: #selector(submitMyDanMuButton(sender:)),
                                    for: .touchUpInside)
        videoSlider.addTarget(self, action: #selector(handleSliderChange(sender:)),
                              for: .valueChanged)
        showChatRoomButton.addTarget(self, action: #selector(showChatroom(sender:)),
                                     for: .touchUpInside)
    }
}
// MARK: - YTPlayerViewDelegate
extension VideoLauncher: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        getVideoDuratiion()
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
        bulletChats.sort()
        bulletChats.forEach({
            if playTime >= $0.popTime {
                danmuView.danmuQueue.append(($0.content, false))
                self.bulletChats.remove(at: 0)
            }
        })
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

// MARK: -
extension VideoLauncher {
    private func setLandscapeAutoLayOut() {
        tableView.removeFromSuperview()
        removeAllContraints()

        NSLayoutConstraint.activate([
            baseView.centerXAnchor.constraint(equalTo: rootViewController.view.centerXAnchor),
            baseView.centerYAnchor.constraint(equalTo: rootViewController.view.centerYAnchor),
            baseView.widthAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
            baseView.heightAnchor.constraint(equalTo: rootViewController.view.heightAnchor),
            ytVideoPlayerView.centerXAnchor.constraint(equalTo: rootViewController.view.centerXAnchor),
            ytVideoPlayerView.centerYAnchor.constraint(equalTo: rootViewController.view.centerYAnchor),
            ytVideoPlayerView.widthAnchor.constraint(equalTo: rootViewController.view.heightAnchor),
            ytVideoPlayerView.heightAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
            buttonsView.centerXAnchor.constraint(equalTo: rootViewController.view.centerXAnchor),
            buttonsView.centerYAnchor.constraint(equalTo: rootViewController.view.centerYAnchor),
            buttonsView.widthAnchor.constraint(equalTo: rootViewController.view.heightAnchor),
            buttonsView.heightAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
            
            changeOrientationButton.centerXAnchor.constraint(equalTo: ytVideoPlayerView.centerXAnchor),
//            changeOrientationButton.rightAnchor.constraint(equalTo: rootViewController.view.rightAnchor, constant: 20),
            changeOrientationButton.centerYAnchor.constraint(equalTo: ytVideoPlayerView.centerYAnchor),
            changeOrientationButton.widthAnchor.constraint(equalToConstant: 40),
            changeOrientationButton.heightAnchor.constraint(equalToConstant: 40),
            
            
            
        ])
    }
    private func setPortraitAutoLayOut() {
        baseView.addSubview(tableView)
        removeAllContraints()
        NSLayoutConstraint.activate([
            baseView.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor),
            baseView.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
            baseView.leftAnchor.constraint(equalTo: rootViewController.view.leftAnchor),
            baseView.widthAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
            baseView.heightAnchor.constraint(equalTo: rootViewController.view.heightAnchor),
            ytVideoPlayerView.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
            ytVideoPlayerView.leftAnchor.constraint(equalTo: rootViewController.view.leftAnchor),
            ytVideoPlayerView.widthAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
            ytVideoPlayerView.heightAnchor.constraint(equalTo: rootViewController.view.widthAnchor, multiplier: 9/16),
            baseView.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
            baseView.leftAnchor.constraint(equalTo: rootViewController.view.leftAnchor),
            baseView.widthAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
            baseView.heightAnchor.constraint(equalTo: rootViewController.view.widthAnchor, multiplier: 9/16),
            tableView.topAnchor.constraint(equalTo: ytVideoPlayerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: rootViewController.view.bottomAnchor),
            buttonsView.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor),
            buttonsView.heightAnchor.constraint(equalTo: rootViewController.view.widthAnchor, multiplier: 9 / 16),
            buttonsView.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
            changeOrientationButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -130),
            changeOrientationButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -16),
            changeOrientationButton.widthAnchor.constraint(equalToConstant: 30),
            changeOrientationButton.heightAnchor.constraint(equalToConstant: 30),
            danmuView.leadingAnchor.constraint(equalTo: ytVideoPlayerView.leadingAnchor),
            danmuView.trailingAnchor.constraint(equalTo: ytVideoPlayerView.trailingAnchor),
            danmuView.topAnchor.constraint(equalTo: ytVideoPlayerView.topAnchor),
            danmuView.heightAnchor.constraint(equalTo: ytVideoPlayerView.heightAnchor, multiplier: 5 / 10),

            showDanMuButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -160),
            showDanMuButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -16),
            showDanMuButton.widthAnchor.constraint(equalToConstant: 30),
            showDanMuButton.heightAnchor.constraint(equalToConstant: 30),
            showDanMuTextFieldButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -200),
            showDanMuTextFieldButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -16),
            showDanMuTextFieldButton.widthAnchor.constraint(equalToConstant: 30),
            showDanMuTextFieldButton.heightAnchor.constraint(equalToConstant: 30),
            pauseButton.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor),
            pauseButton.centerYAnchor.constraint(equalTo: buttonsView.centerYAnchor),
            pauseButton.widthAnchor.constraint(equalToConstant: 50),
            pauseButton.heightAnchor.constraint(equalToConstant: 50),
            videoSlider.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor),
            videoSlider.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -50),
            videoSlider.widthAnchor.constraint(equalTo: buttonsView.widthAnchor, constant: 2),
            videoSlider.heightAnchor.constraint(equalToConstant: 10)
        ])
    }
    private func removeAllContraints() {
        rootViewController.view.removeConstraints(rootViewController.view.constraints)
        baseView.removeConstraints(baseView.constraints)
        ytVideoPlayerView.removeConstraints(ytVideoPlayerView.constraints)
        buttonsView.removeConstraints(buttonsView.constraints)
        changeOrientationButton.removeConstraints(changeOrientationButton.constraints)
        danmuView.removeConstraints(danmuView.constraints)
        showDanMuButton.removeConstraints(showDanMuButton.constraints)
        showDanMuTextFieldButton.removeConstraints(showDanMuTextFieldButton.constraints)
        videoSlider.removeConstraints(videoSlider.constraints)
        tableView.removeConstraints(tableView.constraints)
    }
}

extension VideoLauncher {
    // MARK: - showVideoPlayer
    private func addViews() {
        rootViewController.view.addSubview(baseView)
        baseView.addSubview(ytVideoPlayerView)
        baseView.addSubview(danmuView)
        baseView.addSubview(buttonsView)
        buttonsView.addSubview(showDanMuButton)
        buttonsView.addSubview(showDanMuTextFieldButton)
        buttonsView.addSubview(pauseButton)
        buttonsView.addSubview(changeOrientationButton)
        buttonsView.addSubview(videoSlider)
    }
    func showVideoPlayer() {
        setupVideoLauncher()
        getDanMuData()
        addViews()
        setPortraitAutoLayOut()
        let playerVars: [AnyHashable: Any] = [
            "margin": 0,
            "width": 100,
            //            "height": 100,
            "frameborder": 0,
            "loop": 0,
            "playsigline": 1,
            "controls": 0,
            //                "autohide": 1,
            "showinfo": 0,
            "fs": 0,
//            "rel": 0,
            "autoplay": 1
        ]
        ytVideoPlayerView.load(withVideoId: videoId, playerVars: playerVars)
        baseView.backgroundColor = .white
    }
}

extension VideoLauncher {
    // MARK: - Change Orientation
    @objc func changeOrientation(sender: UIButton) {
        if playerIsShrink == false {
            UIView.animate(withDuration: 0.2, animations: {
                self.baseView.transform = CGAffineTransform(rotationAngle: .pi / 2 )
            }, completion: { _ in
                DispatchQueue.main.async {
                    self.setLandscapeAutoLayOut()
                }
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.baseView.transform = .identity
            }, completion: { _ in
                DispatchQueue.main.async {
                    self.setPortraitAutoLayOut()
                }
            })
        }
        playerIsShrink.toggle()
    }
}
