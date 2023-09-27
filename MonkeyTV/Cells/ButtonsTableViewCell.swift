//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/27.
//

import Foundation
import UIKit

class ButtonsTableViewCell: UITableViewCell {
    static let identifier = "\(ButtonsTableViewCell.self)"
    
//    let array: [String] = [String]()
    let array: [String] = ["無知","風雲變幻施耐庵唉西門吹雪呵呵噠","快看看","窿窿啦啦","一桿禽獸狙","合歡花","暴走大事件","非誠勿擾","呵呵呵"]
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    private lazy var buttonsView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

        contentView.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
            buttonsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: contentView.topAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        for index in 0 ..< array.count {
            let button = UIButton(type: .system)
            button.tag = 100 + index
            button.backgroundColor = UIColor.white
            button.addTarget(self, action: #selector(handleClick(_:)), for: .touchUpInside)
            button.setTitleColor(UIColor.darkGray, for: .normal)
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.cornerRadius = 5
            
            let length = array[index].getLabWidth(font: UIFont.systemFont(ofSize: 16), height: 13).width
            button.setTitle(array[index], for: .normal)
            button.frame = CGRect(x: 10 + width,
                                  y: height,
                                  width: length + 15,
                                  height: 30)
            
            if 10 + width + length + 15 > UIScreen.main.bounds.width {
                width = 0
                height = height + button.frame.size.height + 10
                button.frame = CGRect(x: 10 + width,
                                      y: height,
                                      width: length + 15,
                                      height: 30)
            }
            width = button.frame.size.width + button.frame.origin.x
            buttonsView.addSubview(button)
        }
    }
    @objc func handleClick(_ button: UIButton) {
        print("\(button.tag)")
    }

}
