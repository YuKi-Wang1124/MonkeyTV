//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/1.
//

import UIKit

class MyShowTableViewCell: UITableViewCell {
    static let identifier = "\(MyShowTableViewCell.self)"
    var id: String = ""
    var playlistId: String = ""
    // MARK: - UI
    lazy var showImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.contentMode = .redraw
        imageView.image = UIImage(imageLiteralResourceName: "cat")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var catImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(imageLiteralResourceName: "cat")
        imageview.contentMode = .scaleAspectFill
        imageview.layer.cornerRadius = 4
        imageview.clipsToBounds = true
        imageview.alpha = 0.5
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    private lazy var playImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        imageView.image = UIImage.systemAsset(.playCircle)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var showNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
        showNameLabel.sizeToFit()
    }
    
    override func prepareForReuse() {
        showImageView.image = nil
        showNameLabel.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Auto layout
    private func setupCellUI() {
        
        contentView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        contentView.addSubview(catImageView)
        contentView.addSubview(showImageView)
        contentView.addSubview(playImageView)
        contentView.addSubview(showNameLabel)
        
        NSLayoutConstraint.activate([
            showNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            showNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            showNameLabel.leadingAnchor.constraint(equalTo: showImageView.trailingAnchor, constant: 16),
            showNameLabel.trailingAnchor.constraint(equalTo: playImageView.leadingAnchor, constant: -16),
            
            catImageView.heightAnchor.constraint(equalToConstant: 81),
            catImageView.widthAnchor.constraint(equalToConstant: 144),
            catImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            catImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            showImageView.heightAnchor.constraint(equalToConstant: 81),
            showImageView.widthAnchor.constraint(equalToConstant: 144),
            showImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            showImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            playImageView.heightAnchor.constraint(equalToConstant: 40),
            playImageView.widthAnchor.constraint(equalToConstant: 40),
            playImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            playImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
  
}
