//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/18.
//

import UIKit

class CustomTextField: UITextField {
    
    init(
        text: String,
         backgroundColor: UIColor
    ) {
        super.init(frame: .zero)
        self.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = UIFont.systemFont(ofSize: 18)
        self.backgroundColor = backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
