//
//  FavoriteViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import WebKit
import youtube_ios_player_helper

class FavoriteViewController: UIViewController {
    private var webView: WKWebView!
    private var redView = UIView()
    private var ytview = YTPlayerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        configPlayerView()
        ytview.frame = CGRect(x: 0, y: 320, width: view.frame.width, height: 300)
        redView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.backgroundColor = .white
        let webConfiguration = WKWebViewConfiguration()
//        let url = URL(string: "https://www.youtube.com/embed/DxT1Prn1Lko?si=keHSAgzWFrTl5XHZplaysinline=1")!
        let url = URL(string: "https://www.youtube.com/embed/DxT1Prn1Lko?playsinline=1")!
        let request = URLRequest(url: url)
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webView = WKWebView(frame: CGRect(x: 0, y: 0,
                                          width: view.frame.width,
                                          height: 300),
                            configuration: webConfiguration)
//        redView.frame = webView.frame
        webView.configuration.allowsInlineMediaPlayback = true
        webView.addSubview(redView)
//        view.addSubview(ytview)
        view.addSubview(webView)
        webView.load(request)
        let playButton = UIButton(type: .custom)
        playButton.setTitle("播放", for: .normal)
        playButton.backgroundColor = .yellow
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        playButton.frame = CGRect(x: 0, y: 300, width: 50, height: 50)
        view.addSubview(playButton)
    }
    @objc func playButtonTapped() {
        print("播放禁止")
        let javascript = "document.querySelector('video').play();"
        webView.evaluateJavaScript(javascript) { (result, error) in
            if let error = error {
                print("播放视频时发生错误：\(error.localizedDescription)")
            }
        }
    }
    private func configPlayerView() {
        let playerVars: [AnyHashable: Any] =
        ["playsigline": 1,
         "controls": 1,
         "autohide": 1,
         "showinfo": 0,
         "modestbranding": 0]
        ytview.load(withVideoId: "02lq-eWUiCQ", playerVars: playerVars)
        ytview.delegate = self
    }
}

extension FavoriteViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
//        ytview.customPlayButton.isHidden = true
//        playerView.cuePlaylist(byPlaylistId: "02lq-eWUiCQ", index: 2, startSeconds: 3)
    }
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
            // Handle player state changes
            switch state {
            case .playing:
                // Video is playing
                break
            case .paused:
                // Video is paused
                break
            case .ended:
                // Video playback ended
                break
            default:
                break
            }
        }
}

class CustomYTPlayerView: YTPlayerView {

    let customPlayButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCustomPlayButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCustomPlayButton()
    }

    private func setupCustomPlayButton() {
        customPlayButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        customPlayButton.addTarget(self, action: #selector(customPlayButtonTapped), for: .touchUpInside)
        addSubview(customPlayButton)
        // Customize the play button's position and size
        customPlayButton.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
    }

    @objc private func customPlayButtonTapped() {
        // Handle custom play button tap here
        // You can use the `playVideo()` method to start video playback
        self.playVideo()
    }
}
