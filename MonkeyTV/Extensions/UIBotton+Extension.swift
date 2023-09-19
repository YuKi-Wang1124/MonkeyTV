//
//  UIBotton+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/19.
//

import UIKit

extension UIButton {
    static func createPlayerButton(image: UIImage) -> UIButton {
        let btn = UIButton()
        btn.setImage(image, for: .normal)
        btn.tintColor = .systemGray5
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }
}
