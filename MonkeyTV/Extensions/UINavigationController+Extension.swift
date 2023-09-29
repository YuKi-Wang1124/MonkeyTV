//
//  UIViewController+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit

extension UINavigationController {
    static var home: UINavigationController {
        return addNavigationController(for: HomeViewController(), title: "")
    }
    static var search: UINavigationController {
        return addNavigationController(for: SearchViewController(), title: "搜尋")
    }
    static var favorite: UINavigationController {
        return addNavigationController(for: FavoriteViewController(), title: "我的片單")
    }
    static var profile: UINavigationController {
        return addNavigationController(for: ProfileViewController(), title: "個人化")
    }
    
    private static func addNavigationController(
        for rootViewController: UIViewController,
        title: String?
    ) -> UINavigationController {
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        let barApperance = UINavigationBarAppearance()
        barApperance.shadowColor = UIColor.clear
        navigationController.navigationBar.layer.opacity = 0.9
        navigationController.navigationBar.layer.backgroundColor = UIColor.clear.cgColor
       
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationItem.largeTitleDisplayMode = .automatic
        navigationController.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        ]

        rootViewController.navigationItem.title = title
        return navigationController
    }
}
