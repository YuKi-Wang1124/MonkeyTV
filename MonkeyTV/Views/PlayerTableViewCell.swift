//
//  PlayerTableViewCell.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/22.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    static let identifier = "\(PlayerTableViewCell.self)"
    private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 60)
    lazy var chatRoomButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var chatroomTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.text = "聊天室"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var chatroomNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        label.text = "以匿名的身份公開發表留言..."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var personalImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.image = UIImage.systemAsset(.personalPicture)
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupCellUI() {
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
                constant: 8),
            chatroomTitleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            personalImageView.leadingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                constant: 18),
            personalImageView.widthAnchor.constraint(
                equalToConstant: 28),
            personalImageView.topAnchor.constraint(
                equalTo: chatroomTitleLabel.bottomAnchor, constant: 3),
            personalImageView.heightAnchor.constraint(equalToConstant: 28),
            
            chatRoomButton.leadingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                constant: 8),
            chatRoomButton.trailingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,
                constant: -8),
            chatRoomButton.topAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                constant: 8),
            chatRoomButton.bottomAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.bottomAnchor,
                constant: -8),
            chatRoomButton.heightAnchor.constraint(equalToConstant: 65)
        ])
    }
}
