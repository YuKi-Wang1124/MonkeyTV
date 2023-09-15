//
//  TabBarController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit

class TabBarViewController: UITabBarController {

    private let tabs: [Tab] = [.home, .search, .favorite, .profile]
    private var trolleyTabBarItem: UITabBarItem?
    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = tabs.map { $0.makeViewController() }
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
            controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
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
                return "我的收藏"
            case .profile:
                return "個人"
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
                return .systemAsset(.selectedMagnifyingglass)
            case .favorite:
                return .systemAsset(.selectedHeart)
            case .profile:
                return .systemAsset(.selectedPerson)
            }
        }
    }
}
