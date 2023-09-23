//
//  UILabel+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/23.
//

import UIKit

extension UILabel {
    static func createTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
