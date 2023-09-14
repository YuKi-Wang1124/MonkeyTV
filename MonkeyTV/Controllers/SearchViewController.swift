//
//  ViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit

class SearchViewController: UIViewController {
    lazy var imageView = UIImageView()
    lazy var btn = UIButton()
    let thumbnailUrl = "https://i.ytimg.com/vi/lj6ZOD_k6sY/mqdefault.jpg"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        btn.frame = CGRect(x: 100, y: 300, width: 160, height: 90)
//        imageView.frame = CGRect(x: 0, y: 0, width: 320, height: 180)
        displayThumbnailImage(from: thumbnailUrl)
        btn.addTarget(self, action: #selector(showPlayerVC), for: .touchUpInside)
        view.addSubview(btn)
    }
    @objc func showPlayerVC() {
        let videoLauncher = VideoLauncher()
        videoLauncher.showVideoPlayer()
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
                    print("下载图片时出错：\(error?.localizedDescription ?? "")")
                }
            }
            task.resume()
        }
    }
}
