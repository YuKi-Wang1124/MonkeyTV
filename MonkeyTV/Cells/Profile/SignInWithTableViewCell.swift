//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/6.
//

import Foundation
import UIKit
import GoogleSignIn

class SignInWithTableViewCell: UITableViewCell {
   
    static let identifier = "\(SignInWithTableViewCell.self)"
    
    var iconImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 25
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var signInButton = {
        let button = UIButton()
        button.setTitle("綁定", for: .normal)
        button.setTitleColor(UIColor.setColor(lightColor: .darkGray, darkColor: .white), for: .normal)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
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
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(signInButton)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
//            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            iconImageView.leadingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),

            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 32),
            nameLabel.trailingAnchor.constraint(equalTo: signInButton.leadingAnchor, constant: -32),
            nameLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            
            signInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            signInButton.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 40)

        ])
    }
}
