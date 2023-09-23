//
//  UIViewController+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit

extension UINavigationController {
    static var home: UINavigationController {
        return addNavigationController(viewController: HomeViewController())
    }
    static var search: UINavigationController {
        return addNavigationController(viewController: SearchViewController())
    }
    static var favorite: UINavigationController {
        return addNavigationController(viewController: FavoriteViewController())
    }
    static var profile: UINavigationController {
        return addNavigationController(viewController: ProfileViewController())
    }
    private static func addNavigationController(viewController: UIViewController) -> UINavigationController {
        return UINavigationController(rootViewController: viewController)
    }
}
