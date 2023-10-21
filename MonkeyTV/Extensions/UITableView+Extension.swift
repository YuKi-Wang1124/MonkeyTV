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
}
