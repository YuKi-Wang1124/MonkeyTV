//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/21.
//

import UIKit

class CustomTableView: UITableView {
    
    init(
        rowHeight: CGFloat,
        separatorStyle: UITableViewCell.SeparatorStyle,
        allowsSelection: Bool,
        registerCells: [UITableViewCell.Type]
    ) {
        super.init(frame: .zero, style: .plain)
        self.rowHeight = rowHeight
        self.separatorStyle = separatorStyle
        self.allowsSelection = allowsSelection
        for cellClass in registerCells {
            self.registerCell(cellClass)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
