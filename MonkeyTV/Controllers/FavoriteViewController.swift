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
    private var label = UILabel()
    private var ytview = YTPlayerView()
    private var videoId0 = "FjJtmJteK58"
    private var videoId = "FjJtmJteK58"
    override func viewDidLoad() {
        super.viewDidLoad()
        configPlayerView()
        label.text = "12345678"
        label.frame = CGRect(x: 0, y: 0, width: 30, height: 100)
        ytview.frame = CGRect(x: 0, y: 320, width: view.frame.width, height: 300)
        redView.backgroundColor = UIColor(white: 0, alpha: 0)
        view.backgroundColor = .white
        let webConfiguration = WKWebViewConfiguration()
//        let url = URL(string: "https://www.youtube.com/embed/FjJtmJteK58?si=_By2odwBUTHyUJ3g")!
        let url = URL(string: "https://www.youtube.com/embed/\(videoId0)?fs=0&modestbranding=1&playsinline=1&rel=0")!
        let request = URLRequest(url: url)
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webView = WKWebView(frame: CGRect(x: 0, y: 0,
                                          width: view.frame.width,
                                          height: 300),
                            configuration: webConfiguration)
        redView.frame = ytview.frame
        webView.configuration.allowsInlineMediaPlayback = true
        webView.addSubview(redView)
        view.addSubview(ytview)
        view.addSubview(webView)
        webView.load(request)
        let playButton = UIButton(type: .custom)
        playButton.setTitle("播放", for: .normal)
        playButton.backgroundColor = .yellow
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        playButton.frame = CGRect(x: 0, y: 300, width: 50, height: 50)
//        var html = "<div id ='test'></div>"
//        self.webView.loadHTMLString(html, baseURL: nil)
//        view.addSubview(playButton)
    }
    @objc func playButtonTapped() {
        print("播放禁止")
        let javascript = "document.querySelector('video').play();"
        webView.evaluateJavaScript(javascript) { (result, error) in
            if let error = error {
                print("播放影片時發生錯誤：\(error.localizedDescription)")
            }
        }
    }
    private func configPlayerView() {
        let playerVars: [AnyHashable: Any] =
        ["playsigline": 1,
         "controls": 0,
         "autohide": 1,
         "showinfo": 0,
         "modestbranding": 1,
         "fs": 0,
         "rel": 0]
        ytview.load(withVideoId: videoId, playerVars: playerVars)
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
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let javascript = """
            document.body.style.backgroundColor = 'lightblue';
        """
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
}
