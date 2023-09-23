//
//  UIImage+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import Kingfisher


enum ImageAsset: String {
    case house
    case magnifyingglass
    case heart
    case person
    case selectedHouse = "house.fill"
    case selectedMagnifyingglass
    case selectedHeart = "heart.fill"
    case selectedPerson = "person.fill"
    case square
    case checkmarkSquare = "checkmark.square"
    case submitDanMu = "ellipsis.message.fill"
    case pause = "pause.fill"
    case play = "play.fill"
    case shrink = "arrow.down.right.and.arrow.up.left"
    case enlarge = "arrow.up.left.and.arrow.down.right"
    case chatroom = "text.bubble.fill"
    case personalPicture = "person.crop.circle"
    case send = "paperplane"
    case thumbImage = "circle.fill"
}
extension UIImage {
    static func systemAsset(_ asset: ImageAsset, configuration: UIImage.Configuration? = nil) -> UIImage {
        if let image = UIImage(systemName: asset.rawValue, withConfiguration: configuration) {
            return image
        } else {
            return UIImage()
        }
    }
    static func displayThumbnailImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        if let imageUrl = URL(string: url) {
            let session = URLSession.shared
            let task = session.dataTask(with: imageUrl) { (data, _, error) in
                if error == nil, let imageData = data {
                    if let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                } else {
                    //                    print("下載圖片時錯誤：\(error?.localizedDescription ?? "")")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            task.resume()
        } else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    func loadImage(with url: String, into imageView: UIImageView) {
        if let imageUrl = URL(string: url) {
            let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(
                with: imageUrl,
                placeholder: nil,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
        }
    }
}
