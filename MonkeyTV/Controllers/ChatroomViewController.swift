//
//  ChatroomViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/18.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class ChatroomViewController: UIViewController {
    private lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.estimatedRowHeight = 100
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
    var videoId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        setupUI()
        setupTableView()
        fetchConversations()
        submitMessageButton.addTarget(self, action: #selector(submitMessage), for: .touchUpInside)
    }
    @objc func submitMessage() {
        if let text = messageTextField.text, text.isEmpty == false {
            let id = FirestoreManageer.chatroomCollection.document().documentID
            let data: [String: Any] = ["chatroomChat":
                                        ["chatId": UUID().uuidString,
                                         "content": text,
                                         "contentType": 0,
                                         "createdTime": FirebaseFirestore.Timestamp(),
                                         // TODO: userid
                                         "userId": "匿名"] as [String: Any],
                                       "videoId": videoId,
                                       "id": id]
            FirestoreManageer.chatroomCollection.document(id).setData(data) { error in
                if error != nil {
                    print("Error adding document: (error)")
                } else {
                    self.messageTextField.text = ""
                }
            }
        }
    }
    // MARK: - Setup UI
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
        FirestoreManageer.bulletChatCollection.whereField("videoId", isEqualTo: videoId).getDocuments {
            querySnapshot, error in
            print(self.videoId)
            print(querySnapshot?.count)
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    print(document.data())
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                        let decodedObject = try JSONDecoder().decode(BulletChatData.self, from: jsonData)
                        self.bulletChats.append(decodedObject.bulletChat)
                        print(self.bulletChats)
                    } catch {
                        print("\(error)")
                    }
                }
            }
        }
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
        cell.nameLabel.text = "\(Int.random(in: 1...100000000)) + \(Int.random(in: 1...100000000)) + \(Int.random(in: 1...100000000)) + +++++++++++++++++++++++ "
        cell.messageLabel.text = "\(Int.random(in: 1...100000000)) + \(Int.random(in: 1...100000000)) + \(Int.random(in: 1...100000000)) + \(Int.random(in: 1...100000000000000000))"
        cell.personalImageView.image = UIImage.systemAsset(.personalPicture)
        return cell
    }
}
