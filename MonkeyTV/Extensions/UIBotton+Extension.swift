//
//  UIBotton+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/19.
//

import UIKit

extension UIButton {
    static func createPlayerButton(
        image: UIImage,
        color: UIColor,
        cornerRadius: CGFloat,
        backgroundColor: UIColor = UIColor(white: 0, alpha: 0.2)
    ) -> UIButton {
            
        let button = UIButton()
        button.backgroundColor = backgroundColor
        button.setImage(image, for: .normal)
        button.tintColor = color
        button.layer.cornerRadius = cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
