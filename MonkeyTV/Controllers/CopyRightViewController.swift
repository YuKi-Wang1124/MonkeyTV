//
//  CopyRightViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/12.
//

import UIKit

class CopyRightViewController: UIViewController {
    
    private var copyRightLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.text = "版權資訊"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var copyRightTextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = UIColor.setColor(
            lightColor: UIColor(white: 1, alpha: 0.9),
            darkColor: UIColor(white: 0.1, alpha: 1))
        textView.text = Constant.COPYRIGHT_TEXT
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {

        view.addSubview(copyRightTextView)
        copyRightTextView.contentOffset = CGPoint.zero
        view.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        copyRightTextView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        
        NSLayoutConstraint.activate([
            copyRightTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            copyRightTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            copyRightTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            copyRightTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
}
