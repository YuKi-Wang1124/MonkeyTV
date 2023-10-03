//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/2.
//

import UIKit
import GoogleSignIn
import AuthenticationServices

class ProfileTitleTableViewCell: UITableViewCell {
   
    static let identifier = "\(ProfileTitleTableViewCell.self)"
    
    // MARK: - UI
    lazy var personalImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "歡迎登入 MonkeyTV"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var authorizationButton = {
        let button = ASAuthorizationAppleIDButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var signInButton = {
       let button = GIDSignInButton()
       button.style = .wide
       button.translatesAutoresizingMaskIntoConstraints = false
       return button
   }()
   
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    
    override func prepareForReuse() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Auto layout
    private func setupCellUI() {
        
        contentView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        contentView.addSubview(personalImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(signInButton)
        contentView.addSubview(authorizationButton)

        NSLayoutConstraint.activate([
            personalImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            personalImageView.heightAnchor.constraint(equalToConstant: 120),
            personalImageView.widthAnchor.constraint(equalToConstant: 120),
            personalImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: personalImageView.bottomAnchor, constant: 32),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            signInButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32),
            signInButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signInButton.widthAnchor.constraint(equalToConstant: 120),
            signInButton.heightAnchor.constraint(equalToConstant: 40),

            authorizationButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 16),
            authorizationButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            authorizationButton.widthAnchor.constraint(equalTo: signInButton.widthAnchor, constant: -10),
            authorizationButton.heightAnchor.constraint(equalToConstant: 40),
            authorizationButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)

        ])
    }
}
