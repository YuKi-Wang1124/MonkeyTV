//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/18.
//

import UIKit

extension UITextField {
    static func createTextField(text: String, backgroundColor: UIColor) -> UITextField {
        let textfield = UITextField()
        textfield.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.font = UIFont.systemFont(ofSize: 18)
        textfield.backgroundColor = backgroundColor
//        textfield.layer.borderColor = UIColor.lightGray.cgColor
        return textfield
    }
}
