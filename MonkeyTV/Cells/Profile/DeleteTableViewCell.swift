//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/8.
//

import Foundation
import UIKit

class DeleteTableViewCell: UITableViewCell {
    
    static let identifier = "\(DeleteTableViewCell.self)"
    
    lazy var deleteAccountButton = {
        let button = UIButton()
        button.setTitle("刪除帳號", for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUILayout()
    }
    
    override func prepareForReuse() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUILayout() {
        contentView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        contentView.addSubview(deleteAccountButton)
        
        NSLayoutConstraint.activate([
            deleteAccountButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            deleteAccountButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
