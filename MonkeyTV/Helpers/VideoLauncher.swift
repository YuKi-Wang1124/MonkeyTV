//
//  VideoLauncher.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/14.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        let videoURL = URL(string: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        player = AVPlayer(url: videoURL!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.frame
        playerLayer?.videoGravity = .resizeAspectFill
        self.layer.addSublayer(playerLayer!)
        player?.play()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VideoLauncher: NSObject {
    private var videoPlayerView: VideoPlayerView?
    func showVideoPlayer() {
        if let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).last {
            let view = UIView(frame: keyWindow.frame)
            view.backgroundColor = .white
            view.frame = CGRect(x: keyWindow.frame.width - 10,
                                y: keyWindow.frame.height - 10,
                                width: 10,
                                height: 10)
            let height = keyWindow.frame.width * 9 / 16
            let videoPlayerFrame = CGRect(x: 0, y: 0,
                                          width: keyWindow.frame.width,
                                          height: height)
            videoPlayerView = VideoPlayerView(frame: videoPlayerFrame)
            let playerFrame = videoPlayerFrame
            view.addSubview(videoPlayerView!)
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
}
