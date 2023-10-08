//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/2.
//

import UIKit

class ProfileTitleTableViewCell: UITableViewCell {
    
    static let identifier = "\(ProfileTitleTableViewCell.self)"
    
    lazy var personalImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        let cornerRadius = UIScreen.main.bounds.width / 8
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = true
        imageView.image = UIImage.systemAsset(.personalPicture)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 22)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pencilButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.pencil, configuration: UIImage.symbolConfig),
            color: .white, cornerRadius: 30)
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
        contentView.addSubview(personalImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            personalImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            personalImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/4),
            personalImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/4),
            personalImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            personalImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: personalImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            emailLabel.leadingAnchor.constraint(equalTo: personalImageView.trailingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
        ])
    }
}
