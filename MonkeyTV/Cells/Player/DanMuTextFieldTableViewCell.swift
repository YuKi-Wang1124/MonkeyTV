//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/25.
//

import UIKit

class DanMuTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate, EmptyTextFieldDelegate {
    static let identifier = "\(DanMuTextFieldTableViewCell.self)"
    // MARK: - UI
    private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 60)
    private lazy var danmuBackgroundView = {
        let view = UIView()
        view.backgroundColor = UIColor.setColor(lightColor: .systemGray5, darkColor: .systemGray5)
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var chatroomTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .lightGray)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.text = "彈幕"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var submitMessageButton = {
        return UIButton.createPlayerButton(image: UIImage.systemAsset(.send),
                                           color: .white, cornerRadius: 17)
    }()
    lazy var danMuTextField = {
        return UITextField.createTextField(text: "輸入彈幕")
    }()
    
    // MARK: - Clsoure
    var userInputHandler: ((String) -> Void)?
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text != "" {
            userInputHandler?(text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
    }
    
    // MARK: - Auto layout
    private func setupCellUI() {
        contentView.addSubview(danmuBackgroundView)
        contentView.addSubview(chatroomTitleLabel)
        contentView.addSubview(danMuTextField)
        contentView.addSubview(submitMessageButton)
        contentView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)

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
            danMuTextField.topAnchor.constraint(equalTo: chatroomTitleLabel.bottomAnchor, constant: 4),
            danMuTextField.heightAnchor.constraint(equalToConstant: 35),
            danMuTextField.leadingAnchor.constraint(equalTo: danmuBackgroundView.leadingAnchor, constant: 8),
            danMuTextField.trailingAnchor.constraint(equalTo: submitMessageButton.leadingAnchor, constant: -8),
            danMuTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 4/5),
            submitMessageButton.centerYAnchor.constraint(equalTo: danMuTextField.centerYAnchor),
            submitMessageButton.heightAnchor.constraint(equalToConstant: 34),
            submitMessageButton.widthAnchor.constraint(equalToConstant: 34),
            danmuBackgroundView.leadingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                constant: 8),
            danmuBackgroundView.trailingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,
                constant: -8),
            danmuBackgroundView.topAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                constant: 4),
            danmuBackgroundView.bottomAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.bottomAnchor,
                constant: -8),
            danmuBackgroundView.heightAnchor.constraint(equalToConstant: 80)
            ])
    }
    func emptyTextField() {
        danMuTextField.text = ""
    }
}
