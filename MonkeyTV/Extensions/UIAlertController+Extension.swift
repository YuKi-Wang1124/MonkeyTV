//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/20.
//

import UIKit

extension UIAlertController {
    
    static func showLogInAlert(
        message: String,
        delegate: UIViewController
    ) {
        let alertController = UIAlertController(
            title: Constant.logInFirst,
            message: message,
            preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(title: Constant.goToLogIn, style: .default) { _ in
            self.handleLoginAction(delegate: delegate)
        })
        alertController.addAction(
            UIAlertAction(title: Constant.lookAround, style: .cancel, handler: nil))
        delegate.present(alertController, animated: true, completion: nil)
    }
    
    static func handleLoginAction(
        delegate: UIViewController
    ) {
        delegate.dismiss(animated: true, completion: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 3
        }
    }
}
