//
//  UILabel+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/23.
//

import UIKit

class CustomLabel: UILabel {
    
    init(
        fontSize: CGFloat,
        textColor: UIColor,
        numberOfLines: Int = 0,
        textAlignment: NSTextAlignment = .left
    ) {
        super.init(frame: .zero)
        self.textColor = textColor
        self.font = UIFont.systemFont(ofSize: fontSize)
        self.numberOfLines = numberOfLines
        self.textAlignment = textAlignment
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    init(
        textColor: UIColor,
        numberOfLines: Int = 0,
        textAlignment: NSTextAlignment = .left,
        font: UIFont
    ) {
        super.init(frame: .zero)
        self.textColor = textColor
        self.font = font
        self.numberOfLines = numberOfLines
        self.textAlignment = textAlignment
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    init() {
        super.init(frame: .zero)
        self.textColor = UIColor.lightGray
        self.text = text
        self.font = UIFont.boldSystemFont(ofSize: 24)
        self.textAlignment = .left
        self.numberOfLines = 0
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
