//
//  TabBarController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var notifacatSeachVCdelegate: NotificationSearchViewControllerIsSelectDelegate?
    
    private let tabs: [Tab] = [.home, .search, .favorite, .profile]
    private var trolleyTabBarItem: UITabBarItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        changeInterfaceStyleColor(traitCollection.userInterfaceStyle)
        viewControllers = tabs.map { $0.makeViewController() }
        let barAppearance =  UITabBarAppearance()
        barAppearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = barAppearance
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        changeInterfaceStyleColor(traitCollection.userInterfaceStyle)
    }
    
    @objc func userInterfaceStyleDidChange(notification: Notification) {
        if let userInfo = notification.userInfo?["userInterfaceStyle"] as? UIUserInterfaceStyle {
            changeInterfaceStyleColor(userInfo)
        }
    }
    
    private func changeInterfaceStyleColor(_ userInfo: UIUserInterfaceStyle) {
        if userInfo == .light {
            view.backgroundColor = .white
            view.layer.backgroundColor = UIColor.white.cgColor
            UITabBar.appearance().barTintColor = UIColor.white
            UITabBar.appearance().tintColor = UIColor.mainColor
        } else {
            view.backgroundColor = .black
            view.layer.backgroundColor = UIColor.black.cgColor
            UITabBar.appearance().barTintColor = UIColor.black
            UITabBar.appearance().tintColor = UIColor.mainColor
        }
    }
}

// MARK: - Tabs
extension TabBarViewController {
    private enum Tab {
        case home
        case search
        case favorite
        case profile

        func makeViewController() -> UIViewController {
            let controller: UIViewController
            switch self {
            case .home: controller = UINavigationController.home
            case .search: controller = UINavigationController.search
            case .favorite: controller = UINavigationController.favorite
            case .profile: controller = UINavigationController.profile
            }
            controller.tabBarItem = makeTabBarItem()
            return controller
        }
        
        private func makeTabBarItem() -> UITabBarItem {
            return UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        }
        
        private var title: String {
            switch self {
            case .home:
                return "首頁"
            case .search:
                return "搜尋"
            case .favorite:
                return "我的片單"
            case .profile:
                return "個人化"
            }
        }
        private var image: UIImage? {
            switch self {
            case .home:
                return .systemAsset(.house)
            case .search:
                return .systemAsset(.magnifyingglass)
            case .favorite:
                return  .systemAsset(.heart)
            case .profile:
                return .systemAsset(.person)
            }
        }
        private var selectedImage: UIImage? {
            switch self {
            case .home:
                return .systemAsset(.selectedHouse)
            case .search:
                return .systemAsset(.magnifyingglass)
            case .favorite:
                return .systemAsset(.selectedHeart)
            case .profile:
                return .systemAsset(.selectedPerson)
            }
        }
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        return true
    }
}
