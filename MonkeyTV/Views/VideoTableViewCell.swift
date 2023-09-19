//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/15.
//

import UIKit

class VideoTableViewCell: UITableViewCell {
    static let identifier = "VideoTableViewCell"
    var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    var showNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    var showDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
        contentView.backgroundColor = UIColor.white
    }
    override func prepareForReuse() {
        coverImageView.image = nil
        showNameLabel.text = ""
        showDescriptionLabel.text = ""
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        let views = [coverImageView, showNameLabel, showDescriptionLabel]
        views.forEach {
            self.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            showNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            showNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            showNameLabel.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
