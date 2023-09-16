//
//  VideoLauncher.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/14.
//

import UIKit
import WebKit

class VideoPlayerView: UIView {
    private let controlContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        controlContainerView.frame = frame
        addSubview(controlContainerView)
        self.backgroundColor = .black
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VideoLauncher: NSObject {
    private var videoPlayerView: VideoPlayerView?
    private var webView: WKWebView?
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
            let videoPlayerFrame = CGRect(x: 0, y: 50,
                                          width: keyWindow.frame.width,
                                          height: height)
            let webConfiguration = WKWebViewConfiguration()
            let url = URL(string: "https://www.youtube.com/embed/DxT1Prn1Lko?playsinline=1")!
            let request = URLRequest(url: url)
            webConfiguration.mediaTypesRequiringUserActionForPlayback = []
            webView = WKWebView(frame: CGRect(x: 0, y: 0,
                                              width: view.frame.width,
                                              height: 300),
                                configuration: webConfiguration)
            webView?.configuration.allowsInlineMediaPlayback = true
            webView?.load(request)
            webView?.frame = videoPlayerFrame
            view.addSubview(webView!)
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
