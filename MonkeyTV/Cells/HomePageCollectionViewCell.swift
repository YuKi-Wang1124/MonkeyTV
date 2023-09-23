//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/15.
//

import UIKit

class HomePageCollectionViewCell: UICollectionViewCell {
    static let identifier = "\(HomePageCollectionViewCell.self)"
    var coverImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.layer.cornerRadius = 11
        imageview.clipsToBounds = true
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(coverImageView)
        contentView.addSubview(label)
        label.sizeToFit()
        NSLayoutConstraint.activate([
            coverImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            coverImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6, constant: -16),
            coverImageView.widthAnchor.constraint(equalTo: coverImageView.heightAnchor, multiplier: 16 / 9),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 8)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
