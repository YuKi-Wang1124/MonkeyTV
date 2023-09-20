//
//  UIWindow+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/20.
//

import UIKit

extension UIWindow {
    static func getLastWindow() -> UIWindow {
        if let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).last {
            return keyWindow
        }
        return UIWindow()
    }
}
