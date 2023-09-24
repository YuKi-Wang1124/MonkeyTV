//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/19.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if UIDevice.current.orientation.isPortrait {
            NotificationCenter.default.post(name: UIDevice.orientationDidChangeNotification,
                                            object: nil, userInfo: ["orientation": UIDevice.current.orientation])
        } else if UIDevice.current.orientation.isLandscape {
            NotificationCenter.default.post(name: UIDevice.orientationDidChangeNotification,
                                            object: nil, userInfo: ["orientation": UIDevice.current.orientation])
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

                NotificationCenter.default.post(name: .userInterfaceStyle,
                                                object: nil, userInfo: ["userInterfaceStyle": traitCollection.userInterfaceStyle])

        }
}

import Foundation

extension Notification.Name {
    static let userInterfaceStyle = Notification.Name("userInterfaceStyle")
}
