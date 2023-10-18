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
    
    static func createLabel(fontSize: CGFloat, textColor: UIColor, numberOfLines: Int = 0, textAlignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.textColor = textColor
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.numberOfLines = numberOfLines
        label.textAlignment = textAlignment
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
