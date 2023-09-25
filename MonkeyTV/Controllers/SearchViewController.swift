//
//  ViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import youtube_ios_player_helper

class SearchViewController: UIViewController {
    lazy var imageView = YTPlayerView()
    lazy var btn = UIButton()
    let thumbnailUrl = "https://i.ytimg.com/vi/lj6ZOD_k6sY/mqdefault.jpg"
    override func viewDidLoad() {
        super.viewDidLoad()
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
        imageView.load(withVideoId: "FjJtmJteK58", playerVars: playerVars)

        displayThumbnailImage(from: thumbnailUrl)
//        btn.addTarget(self, action: #selector(showPlayerVC), for: .touchUpInside)
//        view.addSubview(btn)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -500)
        ])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if UIDevice.current.orientation.isLandscape {
//            NSLayoutConstraint.activate([
//                btn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//                btn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//                btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//                btn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//            ])
//            btn.layoutIfNeeded()
        }
        
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [self] context in
            // 在动画过程中更新约束或视图属性
            if size.width > size.height {
                // 横屏模式
                NSLayoutConstraint.activate([
                    self.imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                    self.imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                    self.imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    self.imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                ])
//                self.btn.layoutIfNeeded()
            } else {
                // 竖屏模式
                NSLayoutConstraint.activate([
                    self.imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                    self.imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                    self.imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    self.imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -500)
                ])
//                self.btn.layoutIfNeeded()
            }
        }, completion: { context in
            // 动画完成后执行的操作
        })
    }
    
    
    func displayThumbnailImage(from url: String) {
        if let imageUrl = URL(string: url) {
            let session = URLSession.shared
            let task = session.dataTask(with: imageUrl) { (data, _, error) in
                if error == nil, let imageData = data {
                    DispatchQueue.main.async {
                        if let image = UIImage(data: imageData) {
                            self.btn.setImage(image, for: .normal)
                        }
                    }
                } else {
                    print("下載圖片時錯誤：\(error?.localizedDescription ?? "")")
                }
            }
            task.resume()
        }
    }
}
