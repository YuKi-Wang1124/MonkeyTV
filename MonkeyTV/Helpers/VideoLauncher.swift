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
    private let pauseSymbolConfig = UIImage.SymbolConfiguration(pointSize: 60)
    private var btnsView = UIView()
    private var isPlayerReady = false
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
    private lazy var submitDanMuBtn = {
        return createPlayerBtn(image: UIImage.systemAsset(.submitDanMu, configuration: symbolConfig)!)
    }()
    private lazy var pauseBtn = {
        return createPlayerBtn(image: UIImage.systemAsset(.pause, configuration: pauseSymbolConfig)!)
    }()
    private var danmuView: DanMuView = DanMuView()
    private var timer: Timer?
    override init() {
        super.init()
        DispatchQueue.main.asyncAfter(deadline: .now() + videoDuration) {
            if !self.isPlayerReady {
                print("播放器未在超時前準備就緒。")
            }
        }
        ytVideoPlayerView.delegate = self
        setBtnsAddtarget()
        setDanMu()
    }
    func setDanMu() {
        danmuView.isHidden = true
        danmuView.minSpeed = 1
        danmuView.maxSpeed = 2
        danmuView.gap = 20
        danmuView.lineHeight = 30
        let danmuTimings: [TimeInterval] = [5.0, 10.0, 15.0]
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
        var text = ""
        for _ in 0...Int.random(in: 1...30) {
            text += "嘿"
        }
        for _ in 0...Int.random(in: 1...2) {
            danmuView.addDanMu(text: text, isMycomment: Bool.random())
        }
    }
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
            setYTViewLayout(view: view, notchHeight: notchHeight)
            addBtnsOnBtnView()
            setBtnsAutoLayout()
            let playerVars: [AnyHashable: Any] =
            ["playsigline": 1, "controls": 0,
             "autohide": 1, "showinfo": 0,
             "modestbranding": 1, "fs": 0,
             "rel": 0]
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
    private func createPlayerBtn(image: UIImage) -> UIButton {
        let btn = UIButton()
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }
    // MARK: - Layout
    private func addBtnsOnBtnView() {
        btnsView.addSubview(showDanMuBtn)
        btnsView.addSubview(submitDanMuBtn)
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
            submitDanMuBtn.trailingAnchor.constraint(equalTo: btnsView.trailingAnchor, constant: -200),
            submitDanMuBtn.bottomAnchor.constraint(equalTo: btnsView.bottomAnchor, constant: -16),
            submitDanMuBtn.widthAnchor.constraint(equalToConstant: 30),
            submitDanMuBtn.heightAnchor.constraint(equalToConstant: 30),
            pauseBtn.centerXAnchor.constraint(equalTo: btnsView.centerXAnchor),
            pauseBtn.centerYAnchor.constraint(equalTo: btnsView.centerYAnchor),
            pauseBtn.widthAnchor.constraint(equalToConstant: 60),
            pauseBtn.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    private func setYTViewLayout(view: UIView, notchHeight: CGFloat) {
        btnsView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.addSubview(ytVideoPlayerView)
        view.addSubview(btnsView)
        btnsView.addSubview(danmuView)
        btnsView.translatesAutoresizingMaskIntoConstraints = false
        ytVideoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        danmuView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ytVideoPlayerView.topAnchor.constraint(equalTo: view.topAnchor, constant: notchHeight),
            ytVideoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ytVideoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ytVideoPlayerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ytVideoPlayerView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9 / 16),
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
    // MARK: -
    private func setBtnsAddtarget() {
        showDanMuBtn.addTarget(self, action: #selector(tapBulletBtn(sender:)), for: .touchUpInside)
        submitDanMuBtn.addTarget(self, action: #selector(tapSubmitDanMuBtn(sender:)), for: .touchUpInside)
        pauseBtn.addTarget(self, action: #selector(tapPauseBtn(sender:)), for: .touchUpInside)
        changeOrientationBtn.addTarget(self, action: #selector(tapChangeOrientationBtn(sender:)), for: .touchUpInside)

    }
    @objc func tapSubmitDanMuBtn(sender: UIButton) {
       
    }
    @objc func tapChangeOrientationBtn(sender: UIButton) {
        if playerIsShrink == false {
            sender.setImage(UIImage.systemAsset(.shrink, configuration: pauseSymbolConfig), for: .normal)
        } else {
            sender.setImage(UIImage.systemAsset(.enlarge, configuration: pauseSymbolConfig), for: .normal)
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

extension VideoLauncher: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        ytVideoPlayerView.playVideo()
        isPlayerReady = true
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
