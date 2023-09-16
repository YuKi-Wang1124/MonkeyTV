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
    private var addBtnsView = UIView()
    private var isPlayerReady = false
    private var isBulletDisplayed = false
    private var videoDuration = 7200.0
    private lazy var bulletBtn = {
        var btn = UIButton()
        btn.setImage(UIImage.systemAsset(.square, configuration: symbolConfig), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    var bulletView: BulletView = BulletView()
    var timer: Timer?

    override init() {
        super.init()
        DispatchQueue.main.asyncAfter(deadline: .now() + videoDuration) {
            if !self.isPlayerReady {
                print("播放器未在超時前準備就緒。")
            }
        }
        ytVideoPlayerView.delegate = self
        setBtnsAddtarget()
        bulletView.frame = .init(x: 0, y: 100,
                                 width: ytVideoPlayerView.frame.size.width,
                                 height: ytVideoPlayerView.frame.size.height - 200)
        ytVideoPlayerView.addSubview(bulletView)

        bulletView.minSpeed = 1
        bulletView.maxSpeed = 2
        bulletView.gap = 20
        bulletView.lineHeight = 30
        addBtnsView.addSubview(bulletView)
        bulletView.start()
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self,
                                     selector: #selector(addBullet),
                                     userInfo: nil, repeats: false)
    }
    @objc func addBullet() {
        let interval = CGFloat.random(in: 0.3...1.0)
        Timer.scheduledTimer(timeInterval: interval,
                             target: self, selector: #selector(addBullet),
                             userInfo: nil, repeats: false)
        var text = ""
        for _ in 0...Int.random(in: 1...30) {
            text += "嘿"
        }
        for _ in 0...Int.random(in: 1...2) {
            bulletView.addBullet(text: text, isMe: Bool.random())
        }
    }
    func showVideoPlayer(videoId: String) {
        if let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).last {
            let view = UIView(frame: keyWindow.frame)
            view.backgroundColor = .white
            view.frame = CGRect(x: keyWindow.frame.width - 10,
                                y: keyWindow.frame.height - 10,
                                width: 10,
                                height: 10)
            let height = keyWindow.frame.width * 9 / 16
            let safeAreaInsets = keyWindow.safeAreaInsets
            let topInset = safeAreaInsets.top
            let bottomInset = safeAreaInsets.bottom
            let notchHeight = max(topInset, bottomInset)
            let videoPlayerFrame = CGRect(x: 0, y: notchHeight,
                                          width: keyWindow.frame.width,
                                          height: height)
            let playerVars: [AnyHashable: Any] =
            ["playsigline": 1, "controls": 0,
             "autohide": 1, "showinfo": 0,
             "modestbranding": 1, "fs": 0,
             "rel": 0]
            ytVideoPlayerView.load(withVideoId: videoId, playerVars: playerVars)
            ytVideoPlayerView.frame = videoPlayerFrame
            addBtnsView.frame = ytVideoPlayerView.frame
            addBtnsView.backgroundColor = UIColor(white: 0, alpha: 0)
            addBtnsView.addSubview(bulletBtn)
            setBtnsAutoLayout()
            view.addSubview(ytVideoPlayerView)
            view.addSubview(addBtnsView)
            keyWindow.addSubview(view)
            UIView.animate(withDuration: 0.5, delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                view.frame = keyWindow.frame
            }, completion: { (completedAnimation) in
                // may be do something later
            })
        }
    }
    private func setBtnsAutoLayout() {
        NSLayoutConstraint.activate([
            bulletBtn.trailingAnchor.constraint(equalTo: addBtnsView.trailingAnchor, constant: -160),
            bulletBtn.bottomAnchor.constraint(equalTo: addBtnsView.bottomAnchor, constant: -16),
            bulletBtn.widthAnchor.constraint(equalToConstant: 30),
            bulletBtn.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    private func setBtnsAddtarget() {
        bulletBtn.addTarget(self, action: #selector(tapBulletBtn(sender:)), for: .touchUpInside)
    }
    @objc func tapBulletBtn(sender: UIButton) {
        if !isBulletDisplayed {
            sender.setImage(UIImage.systemAsset(.checkmarkSquare, configuration: symbolConfig), for: .normal)
        } else {
            sender.setImage(UIImage.systemAsset(.square, configuration: symbolConfig), for: .normal)
        }
        isBulletDisplayed.toggle()
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
}

class Bullet {
    var row: Int = 0
    var label: UILabel = UILabel()
    var speed: CGFloat = 0
    var isMe: Bool = false
}

class BulletView: UIView {
    var isPause: Bool = false
    private var displayLink: CADisplayLink?
    var lineHeight: CGFloat = 26
    var gap: CGFloat = 20
    var minSpeed: CGFloat = 1
    var maxSpeed: CGFloat = 2
    
    private var bullets: [Bullet] = []
    private var bulletQueues: [(String, Bool)] = []
    private var timer: Timer?
    
    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: RunLoop.current, forMode: .common)
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:  #selector(handleBulletQueues), userInfo: nil, repeats: true)
    }
    
    @objc func update(_ displayLink: CADisplayLink) {
        if isPause == true {
            return
        }
        for index in 0 ..< bullets.count {
            let bullet = bullets[index]
            bullet.label.frame.origin.x -= bullet.speed
            if bullet.label.frame.origin.x < -bullet.label.frame.size.width {
                bullet.label.removeFromSuperview()
                bullets.remove(at: index)
            }
        }
    }
    @objc func handleBulletQueues() {
        if bulletQueues.isEmpty {
            return
        }
        let bullet = bulletQueues.removeFirst()
        addBullet(text: bullet.0, isMe: bullet.1)
    }
    @objc func addBullet(text: String, isMe: Bool) {
        let bullet = Bullet()
        bullet.label.frame.origin.x = self.frame.size.width
        bullet.label.text = text
        bullet.label.sizeToFit()
        if isMe {
            bullet.label.layer.borderWidth = 1
        }
        var lineLasts: [Bullet?] = []
        let rows: Int = Int(self.frame.size.height / lineHeight)
        for _ in 0 ..< rows {
            lineLasts.append(nil)
        }
        for item in bullets {
            if item.row >= lineLasts.count {
                break
            }
            if lineLasts[item.row] != nil {
                let endXPoint = bullet.label.frame.origin.x
                let targetXPoint = lineLasts[item.row]!.label.frame.origin.x
                if endXPoint > targetXPoint {
                    lineLasts[item.row] = item
                }
            } else {
                lineLasts[item.row] = item
            }
        }
        var isMatch = false
        for index in 0 ..< lineLasts.count {
            if let item = lineLasts[index] {
                let endXPoint = item.label.frame.origin.x + item.label.frame.size.width + gap
                if endXPoint < self.frame.size.width {
                    bullet.row = index
                    var bulletSpeed = self.frame.size.width / endXPoint * item.speed
                    bulletSpeed = CGFloat.minimum(bulletSpeed, maxSpeed)
                    bullet.speed = CGFloat.random(in: minSpeed...bulletSpeed)
                    isMatch = true
                    break
                } else {
                    bullet.row = index
                    bullet.speed = CGFloat.random (in: minSpeed...maxSpeed)
                    isMatch = true
                    break
                }
            }
            if isMatch == false {
                bulletQueues.append ( (text, isMe) )
                return
            }
            bullet.label.frame.origin.y = lineHeight * CGFloat(bullet.row)
            self.addSubview(bullet.label)
            self.bullets.append(bullet)
        }
    }
}
