//
//  PlayerTableViewCell.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/22.
//

import UIKit

class ChatroomButtonTableViewCell: UITableViewCell {
    static let identifier = "\(ChatroomButtonTableViewCell.self)"
    private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 60)
    
    lazy var chatRoomButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.layer.borderWidth = 0.3
        button.layer.cornerRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var chatroomTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .lightGray)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.text = "即時聊天室"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var chatroomNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .lightGray)
        label.backgroundColor = UIColor.setColor(lightColor: .systemGray5, darkColor: .systemGray5)
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var personalImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.image = UIImage.systemAsset(.personalPicture)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupCellUI() {
        contentView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        contentView.addSubview(chatRoomButton)
        chatRoomButton.addSubview(chatroomTitleLabel)
        chatRoomButton.addSubview(personalImageView)
        chatRoomButton.addSubview(chatroomNameLabel)
        
        NSLayoutConstraint.activate([
            chatroomTitleLabel.leadingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                constant: 18),
            chatroomTitleLabel.trailingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,
                constant: -8),
            chatroomTitleLabel.topAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                constant: 10),

            personalImageView.leadingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                constant: 18),
            personalImageView.widthAnchor.constraint(
                equalToConstant: 40),
            personalImageView.topAnchor.constraint(
                equalTo: chatroomTitleLabel.bottomAnchor, constant: 10),
            personalImageView.heightAnchor.constraint(equalToConstant: 40),
            personalImageView.bottomAnchor.constraint(
                equalTo: chatRoomButton.bottomAnchor, constant: -8),
            
            chatroomNameLabel.centerYAnchor.constraint(equalTo: personalImageView.centerYAnchor, constant: 2),
            chatroomNameLabel.heightAnchor.constraint(equalToConstant: 26),
            chatroomNameLabel.leadingAnchor.constraint(equalTo: personalImageView.trailingAnchor, constant: 9),
            chatroomNameLabel.trailingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,
                constant: -24),
            
            chatRoomButton.leadingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                constant: 8),
            chatRoomButton.trailingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,
                constant: -8),
            chatRoomButton.topAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                constant: 0),
            chatRoomButton.bottomAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.bottomAnchor,
                constant: -16),
            chatRoomButton.heightAnchor.constraint(equalToConstant: 88)
        ])
    }
}
