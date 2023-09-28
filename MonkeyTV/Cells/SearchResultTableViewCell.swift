//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/26.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    static let identifier = "\(SearchHistoryTableViewCell.self)"
    // MARK: - UI
    
    private lazy var shmageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemGray2
        imageView.image = UIImage.systemAsset(.history)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var arrowImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemGray2
        imageView.image = UIImage.systemAsset(.searchArrow)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var historyNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 22)
        label.textAlignment = .left
        label.text = "!1234567!"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Auto layout
    private func setupCellUI() {
        contentView.addSubview(clockImageView)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(historyNameLabel)
        
        NSLayoutConstraint.activate([
            historyNameLabel.heightAnchor.constraint(equalToConstant: 30),
            historyNameLabel.leadingAnchor.constraint(equalTo: clockImageView.trailingAnchor, constant: 32),
            historyNameLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -32),
            historyNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            clockImageView.heightAnchor.constraint(equalToConstant: 28),
            clockImageView.widthAnchor.constraint(equalToConstant: 28),
            clockImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            clockImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            arrowImageView.heightAnchor.constraint(equalToConstant: 28),
            arrowImageView.widthAnchor.constraint(equalToConstant: 23),
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
  
}
