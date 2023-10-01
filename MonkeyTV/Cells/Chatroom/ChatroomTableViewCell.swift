//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/18.
//
import UIKit
import FirebaseCore
import FirebaseFirestore

class ChatroomTableViewCell: UITableViewCell {
    
    static let identifier = "\(ChatroomTableViewCell.self)"
    // MARK: - UI
    var personalImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    // MARK: - Setup Cell UI
    private func setupCellUI() {
        let screenWidth = UIScreen.main.bounds.width
        contentView.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        contentView.addSubview(personalImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageLabel)
        contentView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)

        NSLayoutConstraint.activate([
            personalImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            personalImageView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor,
                                                        constant: -4),
            personalImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            personalImageView.heightAnchor.constraint(equalToConstant: 30),
            personalImageView.widthAnchor.constraint(equalToConstant: 30),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
