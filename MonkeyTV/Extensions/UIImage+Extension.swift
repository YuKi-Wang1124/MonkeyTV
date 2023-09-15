//
//  UIImage+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit

enum ImageAsset: String {
    case house
    case magnifyingglass
    case heart
    case person
    case selectedHouse = "house.fill"
    case selectedMagnifyingglass
    case selectedHeart = "heart.fill"
    case selectedPerson = "person.fill"
}

extension UIImage {

    static func systemAsset(_ asset: ImageAsset) -> UIImage? {
        return UIImage(systemName: asset.rawValue)
    }
}
