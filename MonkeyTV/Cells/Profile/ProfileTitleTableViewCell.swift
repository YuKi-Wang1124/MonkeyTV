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
         imageView.layer.cornerRadius = 65
         imageView.clipsToBounds = true
         imageView.image = UIImage.systemAsset(.personalPicture)
         imageView.translatesAutoresizingMaskIntoConstraints = false
         return imageView
     }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
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
        
        NSLayoutConstraint.activate([
            personalImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 32),
            personalImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/3),
            personalImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/3),
            personalImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: personalImageView.bottomAnchor, constant: 32),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)

        ])
    }
}
