//
//  ViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit

class SearchViewController: UIViewController {
    
    lazy var imageView = UIImageView()
    let thumbnailUrl = "https://yt3.ggpht.com/V5mmM1zyMzwYeeFmYDvsIUnZ3DZ6GgC5J0TYUP4-QjA6LpmNU03st76cjmyzxFE07o_z-PmHCw=s240-c-k-c0x00ffffff-no-rj"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        
        displayThumbnailImage(from: thumbnailUrl)

        view.addSubview(imageView)
    }
    func displayThumbnailImage(from url: String) {
        if let imageUrl = URL(string: url) {
            let session = URLSession.shared
            let task = session.dataTask(with: imageUrl) { (data, response, error) in
                if error == nil, let imageData = data {
                    DispatchQueue.main.async {
                        if let image = UIImage(data: imageData) {
                            self.imageView.image = image
                        }
                    }
                } else {
                    print("下载图片时出错：\(error?.localizedDescription ?? "")")
                }
            }
            task.resume()
        }
    }

    // 在你的代码中调用这个函数，将从 YouTube API 获取的照片 URL 传递给它
   
}

