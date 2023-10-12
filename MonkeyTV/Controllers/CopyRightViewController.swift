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
    
    //swiftlint: disable line_length
    private let text = "MonkeyTV App 遵守 YouTube API 服務條款的第三方播放器，所有 YouTube 影片皆是透過官方提供的 API 嵌入式播放器進行播放，所有外部連結的影片皆連結至官方網頁的公開影片。若有任何疑問或指教，煩請來信: demomandy24@gmail.com \n\nMonkeyTV App is a third-party player that complies with the YouTube API terms of service. All YouTube videos are played through the official embedded player provided by the API. All external links to videos lead to publicly available videos on the official website. If you have any questions or feedback, please feel free to email us. demomandy24@gmail.com"
    //swiftlint: disable line_length

    private lazy var copyRightTextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = UIColor.setColor(
            lightColor: UIColor(white: 1, alpha: 0.9),
            darkColor: UIColor(white: 0.1, alpha: 1))
        textView.text = text
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
//        view.addSubview(copyRightLabel)
        view.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        copyRightTextView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        
        NSLayoutConstraint.activate([
//            copyRightLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            copyRightLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
//            copyRightLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            copyRightLabel.bottomAnchor.constraint(equalTo: copyRightTextView.safeAreaLayoutGuide.topAnchor, constant: -16),
//
            copyRightTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            copyRightTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            copyRightTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            copyRightTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)

        ])
    }
}
