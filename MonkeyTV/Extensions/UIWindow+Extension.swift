//
//  UIWindow+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/20.
//

import UIKit

extension UIViewController {
    static func getFirstViewController() -> UIViewController {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return keyWindow.rootViewController!
        }
        return UIViewController()
    }
}
