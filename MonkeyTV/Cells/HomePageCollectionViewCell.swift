//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/15.
//

import UIKit

class HomePageCollectionViewCell: UICollectionViewCell {
    static let identifier = "\(HomePageCollectionViewCell.self)"
    var containerView: UIView = {
        var containerView = UIView()
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        containerView.layer.shadowOpacity = 0.35
        containerView.layer.shadowOffset = CGSize(width: 5, height: 5)
        containerView.layer.shadowRadius = 5
        containerView.layer.masksToBounds = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    var catImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(imageLiteralResourceName: "cat")
        imageview.contentMode = .scaleAspectFill
        imageview.layer.cornerRadius = 6
        imageview.clipsToBounds = true
        imageview.alpha = 0.5
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    var coverImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .redraw
        imageview.layer.cornerRadius = 6
        imageview.clipsToBounds = true
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var playlistId: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellUI() {
        contentView.backgroundColor = .systemGray6
        containerView.addSubview(catImageView)
        containerView.addSubview(coverImageView)
        contentView.addSubview(containerView)
        contentView.addSubview(label)
        label.sizeToFit()
        NSLayoutConstraint.activate([
            catImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            catImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            catImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            catImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            coverImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            containerView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.55, constant: -16),
            containerView.widthAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 16 / 9),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 10)
        ])
    }
}
