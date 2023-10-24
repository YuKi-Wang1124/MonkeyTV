//
//  UIBotton+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/19.
//

import UIKit

class CustomButton: UIButton {
    
    init(
        image: UIImage,
        color: UIColor,
        cornerRadius: CGFloat,
        backgroundColor: UIColor = UIColor(white: 0, alpha: 0.2)
    ) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.setImage(image, for: .normal)
        self.tintColor = color
        self.layer.cornerRadius = cornerRadius
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
