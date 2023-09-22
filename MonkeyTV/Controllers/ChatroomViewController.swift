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
    private var chatroomTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .left
        label.text = "聊天室"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var submitMessageButton = {
        return UIButton.createPlayerButton(image: UIImage.systemAsset(.send),
                                           color: .white, cornerRadius: 20)
    }()
    private lazy var messageTextField = {
        return UITextField.createTextField(text: "輸入訊息")
    }()
    private var viewModel: ChatroomViewModel = ChatroomViewModel()
    var videoId: String = ""
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.dataSource = viewModel.dataSource
        viewModel.configureDataSource(tableView: self.tableView)
        bindingViewModel()
        setupUI()
        submitMessageButton.addTarget(self, action: #selector(submitMessage), for: .touchUpInside)
    }
    deinit {
    }
    // MARK: - Submit Message To DB
    @objc func submitMessage() {
        if let text = messageTextField.text, text.isEmpty == false {
            let id = FirestoreManageer.chatroomCollection.document().documentID
            let data: [String: Any] =
            ["chatroomChat":
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
    func bindingViewModel() {
        let now = FirebaseFirestore.Timestamp().dateValue()
        viewModel.fetchConversation(currentTime: now)
        viewModel.isLoading.bind { [weak self] isLoading in
            guard let self, let isLoading = isLoading else {
                return
            }
            DispatchQueue.main.async {
                if isLoading {
                } else {
                    return
                }
            }
        }
    }
}
// MARK: -
extension ChatroomViewController {
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(submitMessageButton)
        view.addSubview(tableView)
        view.addSubview(submitMessageButton)
        view.addSubview(messageTextField)
        view.addSubview(chatroomTitleLabel)

        NSLayoutConstraint.activate([
            chatroomTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 26),
            chatroomTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
          
            chatroomTitleLabel.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            
            messageTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            messageTextField.trailingAnchor.constraint(equalTo: submitMessageButton.leadingAnchor, constant: -8),
            messageTextField.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            messageTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            submitMessageButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
//            submitMessageButton.topAnchor.constraint(equalTo: tableView.bottomAnchor),
//
//            submitMessageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            submitMessageButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            submitMessageButton.heightAnchor.constraint(equalToConstant: 40),
            
            messageTextField.widthAnchor.constraint(equalTo: submitMessageButton.widthAnchor, multiplier: 7)
        ])
    }
}
