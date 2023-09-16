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
    private var bulletView = UIView()
    private var isPlayerReady = false
    override init() {
        super.init()
        ytVideoPlayerView.delegate = self
    }
    func showVideoPlayer(videoId: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            if !self.isPlayerReady {
                print("播放器位在超時前準備就緒。")
            }
        }
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
            let url = URL(string: "https://www.youtube.com/embed/\(videoId)")!
            let request = URLRequest(url: url)
            let playerVars: [AnyHashable: Any] = ["playsigline": 1,
                                                  "controls": 0,
                                                  "autohide": 1,
                                                  "showinfo": 0,
                                                  "modestbranding": 1,
                                                  "fs": 0,
                                                  "rel": 0]
            ytVideoPlayerView.load(withVideoId: videoId, playerVars: playerVars)
            ytVideoPlayerView.frame = videoPlayerFrame
            bulletView.frame = ytVideoPlayerView.frame
            bulletView.backgroundColor = UIColor(white: 0, alpha: 0.1)
            view.addSubview(ytVideoPlayerView)
//            view.addSubview(bulletView)
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

extension VideoLauncher: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        isPlayerReady = true
        ytVideoPlayerView.playVideo()
    }
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        // Handle player state changes
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
}
