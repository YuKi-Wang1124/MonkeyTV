//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/15.
//

import UIKit
//import iCarousel

class HomeAnimationTableViewCell: UITableViewCell {
    
    static let identifier = "\(HomeAnimationTableViewCell.self)"
//    
//    let carousel: iCarousel = {
//        let view = iCarousel()
//        view.type = .coverFlow
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
//    var coverImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        return imageView
//    }()
//
//    var showNameLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.black
//        label.font = UIFont.systemFont(ofSize: 15)
//        return label
//    }()
//
//    var showDescriptionLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.black
//        label.font = UIFont.systemFont(ofSize: 15)
//        return label
//    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    override func prepareForReuse() {
  
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
//        contentView.addSubview(carousel)
//
//        NSLayoutConstraint.activate([
//            carousel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//            carousel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
//            carousel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
//            carousel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
//        ])
    }
}
