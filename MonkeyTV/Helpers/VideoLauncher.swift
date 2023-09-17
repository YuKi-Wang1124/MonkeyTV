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
    private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30)
    private let pauseSymbolConfig = UIImage.SymbolConfiguration(pointSize: 50)
    private var btnsView = UIView()
    private var isDanMuDisplayed = false
    private var videoIsPlaying = true
    private var playerIsShrink = false
    private var videoDuration = 7200.0
    private lazy var changeOrientationBtn = {
        return createPlayerBtn(image: UIImage.systemAsset(.enlarge, configuration: symbolConfig)!)
    }()
    private lazy var showDanMuBtn = {
        return createPlayerBtn(image: UIImage.systemAsset(.square, configuration: symbolConfig)!)
    }()
    private lazy var addDanMuBtn = {
        return createPlayerBtn(image: UIImage.systemAsset(.submitDanMu, configuration: symbolConfig)!)
    }()
    private lazy var pauseBtn = {
        return createPlayerBtn(image: UIImage.systemAsset(.pause, configuration: pauseSymbolConfig)!)
    }()
    private lazy var submitDanMuBtn = {
        let btn = UIButton()
        btn.setTitle("送出彈幕", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    private lazy var danMuTextField = {
       return createTextField(text: "輸入彈幕")
    }()
    private var danmuView: DanMuView = DanMuView()
    private var timer: Timer?
    // MARK: - init
    override init() {
        super.init()
        ytVideoPlayerView.backgroundColor = .black
        ytVideoPlayerView.delegate = self
        setBtnsAddtarget()
        setDanMu()
    }
    // MARK: - setDanMu
    func setDanMu() {
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
    // MARK: - showVideoPlayer
    func showVideoPlayer(videoId: String) {
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
            // TODO:
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
    // MARK: - Create UI Object
    private func createPlayerBtn(image: UIImage) -> UIButton {
        let btn = UIButton()
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }
    private func createTextField(text: String) -> UITextField {
        let textfield = UITextField()
        textfield.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.font = UIFont.systemFont(ofSize: 18)
        textfield.borderStyle = .roundedRect
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        return textfield
    }
    // MARK: - Layout
    private func addBtnsOnBtnView() {
        btnsView.addSubview(showDanMuBtn)
        btnsView.addSubview(addDanMuBtn)
        btnsView.addSubview(pauseBtn)
        btnsView.addSubview(changeOrientationBtn)
    }
    private func setBtnsAutoLayout() {
        NSLayoutConstraint.activate([
            changeOrientationBtn.trailingAnchor.constraint(equalTo: btnsView.trailingAnchor, constant: -130),
            changeOrientationBtn.bottomAnchor.constraint(equalTo: btnsView.bottomAnchor, constant: -16),
            changeOrientationBtn.widthAnchor.constraint(equalToConstant: 30),
            changeOrientationBtn.heightAnchor.constraint(equalToConstant: 30),
            showDanMuBtn.trailingAnchor.constraint(equalTo: btnsView.trailingAnchor, constant: -160),
            showDanMuBtn.bottomAnchor.constraint(equalTo: btnsView.bottomAnchor, constant: -16),
            showDanMuBtn.widthAnchor.constraint(equalToConstant: 30),
            showDanMuBtn.heightAnchor.constraint(equalToConstant: 30),
            addDanMuBtn.trailingAnchor.constraint(equalTo: btnsView.trailingAnchor, constant: -200),
            addDanMuBtn.bottomAnchor.constraint(equalTo: btnsView.bottomAnchor, constant: -16),
            addDanMuBtn.widthAnchor.constraint(equalToConstant: 30),
            addDanMuBtn.heightAnchor.constraint(equalToConstant: 30),
            pauseBtn.centerXAnchor.constraint(equalTo: btnsView.centerXAnchor),
            pauseBtn.centerYAnchor.constraint(equalTo: btnsView.centerYAnchor),
            pauseBtn.widthAnchor.constraint(equalToConstant: 50),
            pauseBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    private func addYTView(view: UIView) {
        btnsView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        
        view.addSubview(ytVideoPlayerView)
        view.addSubview(btnsView)
        btnsView.addSubview(danmuView)
        view.addSubview(danMuTextField)
        view.addSubview(submitDanMuBtn)
        btnsView.translatesAutoresizingMaskIntoConstraints = false
        ytVideoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        danmuView.translatesAutoresizingMaskIntoConstraints = false
    }
    private func setYTViewLayout(view: UIView, notchHeight: CGFloat) {
        NSLayoutConstraint.activate([
            submitDanMuBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitDanMuBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            submitDanMuBtn.widthAnchor.constraint(equalToConstant: 150),
            submitDanMuBtn.heightAnchor.constraint(equalToConstant: 50),
            danMuTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            danMuTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            danMuTextField.widthAnchor.constraint(equalToConstant: 300),
            danMuTextField.heightAnchor.constraint(equalToConstant: 50),
            ytVideoPlayerView.topAnchor.constraint(equalTo: view.topAnchor, constant: notchHeight),
            ytVideoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ytVideoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ytVideoPlayerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ytVideoPlayerView.heightAnchor.constraint(equalTo: ytVideoPlayerView.widthAnchor, multiplier: 9 / 16),
            btnsView.leadingAnchor.constraint(equalTo: ytVideoPlayerView.leadingAnchor),
            btnsView.trailingAnchor.constraint(equalTo: ytVideoPlayerView.trailingAnchor),
            btnsView.topAnchor.constraint(equalTo: ytVideoPlayerView.topAnchor),
            btnsView.bottomAnchor.constraint(equalTo: ytVideoPlayerView.bottomAnchor),
            danmuView.leadingAnchor.constraint(equalTo: ytVideoPlayerView.leadingAnchor),
            danmuView.trailingAnchor.constraint(equalTo: ytVideoPlayerView.trailingAnchor),
            danmuView.topAnchor.constraint(equalTo: ytVideoPlayerView.topAnchor),
            danmuView.heightAnchor.constraint(equalTo: ytVideoPlayerView.heightAnchor, multiplier: 5 / 10)
        ])
    }
    private func setLandscapeYTViewLayout(view: UIView) {
        NSLayoutConstraint.activate([
            ytVideoPlayerView.topAnchor.constraint(equalTo: view.topAnchor),
            ytVideoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ytVideoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ytVideoPlayerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ytVideoPlayerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            btnsView.leadingAnchor.constraint(equalTo: ytVideoPlayerView.leadingAnchor),
            btnsView.trailingAnchor.constraint(equalTo: ytVideoPlayerView.trailingAnchor),
            btnsView.topAnchor.constraint(equalTo: ytVideoPlayerView.topAnchor),
            btnsView.bottomAnchor.constraint(equalTo: ytVideoPlayerView.bottomAnchor),
            danmuView.leadingAnchor.constraint(equalTo: ytVideoPlayerView.leadingAnchor),
            danmuView.trailingAnchor.constraint(equalTo: ytVideoPlayerView.trailingAnchor),
            danmuView.topAnchor.constraint(equalTo: ytVideoPlayerView.topAnchor),
            danmuView.heightAnchor.constraint(equalTo: ytVideoPlayerView.heightAnchor, multiplier: 5 / 10)
        ])
    }
    // MARK: - Buttons AddTaget
    private func setBtnsAddtarget() {
        showDanMuBtn.addTarget(self, action: #selector(tapBulletBtn(sender:)), for: .touchUpInside)
        addDanMuBtn.addTarget(self, action: #selector(tapSubmitDanMuBtn(sender:)), for: .touchUpInside)
        pauseBtn.addTarget(self, action: #selector(tapPauseBtn(sender:)), for: .touchUpInside)
        changeOrientationBtn.addTarget(self, action: #selector(tapChangeOrientationBtn(sender:)), for: .touchUpInside)
        submitDanMuBtn.addTarget(self, action: #selector(tapSubmitDanMuBtn(sender:)), for: .touchUpInside)
    }
    // MARK: - Buttons objc functions
    @objc func tapSubmitDanMuBtn(sender: UIButton) {
        if let text = danMuTextField.text, text.isEmpty == false {
            danmuView.danmuQueue.append((text, false))
        }
    }
    @objc func tapChangeOrientationBtn(sender: UIButton) {
        if playerIsShrink == false {
            sender.setImage(UIImage.systemAsset(.shrink, configuration: symbolConfig), for: .normal)
        } else {
            sender.setImage(UIImage.systemAsset(.enlarge, configuration: symbolConfig), for: .normal)
        }
        playerIsShrink.toggle()
    }
    @objc func tapPauseBtn(sender: UIButton) {
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
// MARK: -
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
//
//    }
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
//        print("\(playTime)")
    }
    func getVideoDuratiion() {
        ytVideoPlayerView.duration { (duration, error) in
            if let error = error {
                print("無法取得時間：\(error.localizedDescription)")
            } else {
                self.videoDuration = duration
                print("影片總時間：\(duration) 秒")
            }
        }
    }
}
