//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/15.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    static let identifier = "\(VideoCollectionViewCell.self)"
    var coverBtn = {
        let btn = UIButton()
        btn.contentMode = .scaleAspectFill
        btn.clipsToBounds = true
        return btn
    }()
    var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(coverBtn)
        contentView.addSubview(label)
        coverBtn.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coverBtn.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coverBtn.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverBtn.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.48, constant: -10),
            coverBtn.widthAnchor.constraint(equalTo: coverBtn.heightAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: coverBtn.bottomAnchor, constant: 8),
            label.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.36)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
