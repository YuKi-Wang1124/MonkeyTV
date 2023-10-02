//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/30.
//

import UIKit

class PlayerTitleTableViewCell: UITableViewCell, ChangeCellButtonDelegate {
   
    static let identifier = "\(PlayerTitleTableViewCell.self)"
    var id: String = ""
    var playlistId: String = ""
    
    // MARK: - UI
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
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    
    override func prepareForReuse() {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Auto layout
    private func setupCellUI() {
        
        contentView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        contentView.addSubview(addButton)
        contentView.addSubview(addLabel)
        
        NSLayoutConstraint.activate([
            
            addButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            addButton.heightAnchor.constraint(equalToConstant: 40),
            addButton.widthAnchor.constraint(equalToConstant: 40),
            
            addLabel.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
            addLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 4)
                        
        ])
    }
    
    func changeButtonImage() {
        
        addButton.setImage(UIImage.systemAsset(.checkmark, configuration: UIImage.symbolConfig), for: .normal)
    }
    
    func changeVideoTitle(text: String) {
//        showNameLabel.text = text
    }
    
}
