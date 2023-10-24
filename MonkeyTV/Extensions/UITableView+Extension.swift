//
//  UITableView+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/21.
//

import UIKit

extension UITableView {
    
    func registerCell<T: UITableViewCell>(_ cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: "\(T.self)", for: indexPath) as? T else {
            fatalError("Failed to dequeue cell with identifier: \(T.self)")
        }
        return cell
    }
}
