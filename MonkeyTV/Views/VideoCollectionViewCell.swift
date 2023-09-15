//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/15.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "\(VideoCollectionViewCell.self)"
    
    private let view = UIView()
    
    var coverImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var showNameLabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "厚實毛呢格子外套"
        return label
    }()
    
    var showDescriptionLabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "NT$2140"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(view)
        view.addSubview(coverImageView)
        view.addSubview(showNameLabel)
        view.addSubview(showDescriptionLabel)

        view.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        showNameLabel.translatesAutoresizingMaskIntoConstraints = false
        showDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),

            coverImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            coverImageView.topAnchor.constraint(equalTo: view.topAnchor,constant: 18),
            
            coverImageView.heightAnchor.constraint(equalToConstant: 230),

            showNameLabel.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor),
            showNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            showNameLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 12),

            showDescriptionLabel.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor),
            showDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            showDescriptionLabel.topAnchor.constraint(equalTo: showNameLabel.bottomAnchor, constant: 8),
            showDescriptionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])
    }
    override func prepareForReuse() {
        coverImageView.image = nil
        showNameLabel.text = ""
        showDescriptionLabel.text = ""
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
