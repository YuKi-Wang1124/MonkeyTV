//
//  ChatroomViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/18.
//

import UIKit

class ChatroomViewController: UIViewController {
    private lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ChatroomTableViewCell.self,
                           forCellReuseIdentifier: ChatroomTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private lazy var submitMessageButton = {
        let button = UIButton()
        button.setTitle("送出", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var noConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "沒有對話"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    private lazy var messageTextField = {
        return UITextField.createTextField(text: "輸入訊息")
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        setupUI()
        setupTableView()
        fetchConversations()
    }
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(submitMessageButton)
        view.addSubview(messageTextField)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            messageTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: submitMessageButton.leadingAnchor),
            messageTextField.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            messageTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            submitMessageButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            submitMessageButton.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            submitMessageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageTextField.widthAnchor.constraint(equalTo: submitMessageButton.widthAnchor, multiplier: 7)
        ])
    }
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(submitMessageButton)
    }
    private func fetchConversations() {
    }
}

extension ChatroomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        30
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatroomTableViewCell.identifier,
                                                 for: indexPath) as? ChatroomTableViewCell
        guard let cell else { return UITableViewCell() }
        cell.nameLabel.text = "\(Int.random(in: 1...100000000))"
        cell.messageLabel.text = "\(Int.random(in: 1...100000000000000000))"
        cell.personalImageView.image = UIImage.systemAsset(.personalPicture)
        return cell
    }
}
