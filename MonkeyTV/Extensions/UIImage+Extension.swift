//
//  UIImage+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import Kingfisher

enum ImageAsset: String {
    case chatroom = "text.bubble.fill"
    case cCircle = "c.circle"
    case checkmark
    case checkmarkSquare = "checkmark.square"
    case clock = "clock.fill"
    case flag
    case heart
    case history = "clock.arrow.circlepath"
    case house
    case enlarge = "arrow.up.left.and.arrow.down.right"
    case magnifyingglass
    case nosign
    case pause = "pause.fill"
    case pencil
    case person
    case personalPicture = "person.crop.circle"
    case play = "play.fill"
    case playCircle = "play.circle"
    case plus
    case searchArrow = "arrow.up.backward"
    case selectedHeart = "heart.fill"
    case selectedHouse = "house.fill"
    case selectedMagnifyingglass
    case selectedPerson = "person.fill"
    case paperplane
    case shrink = "arrow.down.right.and.arrow.up.left"
    case square
    case submitDanMu = "ellipsis.message.fill"
    case thumbImage = "circle.fill"
    case trash = "trash.fill"
    case xmark
}

extension UIImage {
    
    static let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30)
    static let smallSymbolConfig = UIImage.SymbolConfiguration(pointSize: 20)

    static func systemAsset(
        _ asset: ImageAsset,
        configuration: UIImage.Configuration? = nil
    ) -> UIImage {
        if let image = UIImage(systemName: asset.rawValue, withConfiguration: configuration) {
            return image
        } else {
            return UIImage()
        }
    }
    
    static func displayThumbnailImage(
        from url: String,
        completion: @escaping (UIImage?) -> Void) {
            
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
                    print("下載圖片時錯誤：\(error?.localizedDescription ?? "")")
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
    
    func loadImage(
        with url: String,
        into imageView: UIImageView
    ) {
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
