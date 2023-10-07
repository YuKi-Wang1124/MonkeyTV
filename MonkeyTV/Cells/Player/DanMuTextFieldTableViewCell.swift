//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/25.
//

import UIKit

class DanMuTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate, EmptyTextFieldDelegate, ChangeCellButtonDelegate {
    static let identifier = "\(DanMuTextFieldTableViewCell.self)"
    // MARK: - UI
    private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 60)
    
    private lazy var addButtonView = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.borderWidth = 0.3
        view.layer.cornerRadius = 4
        return view
    }()
    
    lazy var addButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.plus, configuration: UIImage.symbolConfig),
            color: UIColor.setColor(lightColor: .darkGray, darkColor: .white),
            cornerRadius: 0, backgroundColor: .clear)
    }()
    
    private lazy var addLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = "加入片單"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        let button = UIButton.createPlayerButton(
            image: UIImage.systemAsset(.send,configuration: UIImage.symbolConfig),
            color: UIColor.lightGray, cornerRadius: 4)
        button.backgroundColor = UIColor.systemGray5
        return button
    }()
    
    lazy var danMuTextField = {
        let textfield = UITextField.createTextField(
            text: "  輸入彈幕留下評論",
            backgroundColor: UIColor.systemGray5)
        textfield.layer.cornerRadius = 4
        return textfield
    }()
    
    var id: String = ""
    var playlistId: String = ""
    
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
        contentView.addSubview(danMuTextField)
        contentView.addSubview(submitMessageButton)
        contentView.addSubview(addButton)
        contentView.addSubview(addLabel)

        contentView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)

        NSLayoutConstraint.activate([
            
            addButton.heightAnchor.constraint(equalToConstant: 40),
            addButton.widthAnchor.constraint(equalToConstant: 40),
            
            addButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            addButton.bottomAnchor.constraint(equalTo: addLabel.topAnchor),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            addButton.trailingAnchor.constraint(equalTo: danMuTextField.leadingAnchor, constant: -32),

            addLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            addLabel.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
            addLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 12),

            danMuTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            danMuTextField.trailingAnchor.constraint(equalTo: submitMessageButton.leadingAnchor, constant: 4),
            danMuTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 3/5),
            danMuTextField.heightAnchor.constraint(equalTo: submitMessageButton.heightAnchor),

            submitMessageButton.heightAnchor.constraint(equalToConstant: 80),
            submitMessageButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            submitMessageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            submitMessageButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            ])
    }
    func emptyTextField() {
        danMuTextField.text = ""
    }
    
    func changeButtonImage() {
        
        addButton.setImage(UIImage.systemAsset(.checkmark, configuration: UIImage.symbolConfig), for: .normal)
    }
    
}
