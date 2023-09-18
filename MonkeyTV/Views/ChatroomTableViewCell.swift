//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/18.
//
import UIKit

class ChatroomTableViewCell: UITableViewCell {
    static let identifier = "\(ChatroomTableViewCell.self)"
    var coverButton = {
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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(coverButton)
        contentView.addSubview(label)
        coverButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coverButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coverButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverButton.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.48, constant: -10),
            coverButton.widthAnchor.constraint(equalTo: coverButton.heightAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: coverButton.bottomAnchor, constant: 8),
            label.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.36)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
