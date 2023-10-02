//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/2.
//

import UIKit
import GoogleSignIn

class ProfileTitleTableViewCell: UITableViewCell {
   
    static let identifier = "\(ProfileTitleTableViewCell.self)"
    
    // MARK: - UI
    lazy var personalImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 80
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var addLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = "加入片單"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var signInButton = GIDSignInButton()

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
        contentView.addSubview(addLabel)
        contentView.addSubview(signInButton)

        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            personalImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            personalImageView.heightAnchor.constraint(equalToConstant: 160),
            personalImageView.widthAnchor.constraint(equalToConstant: 160),
            personalImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            signInButton.topAnchor.constraint(equalTo: personalImageView.bottomAnchor, constant: 32),
            signInButton.widthAnchor.constraint(equalToConstant: 200),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            signInButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signInButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),

            
        ])
    }
}
