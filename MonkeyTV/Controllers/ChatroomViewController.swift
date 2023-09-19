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
        return UIButton.createPlayerButton(image: UIImage.systemAsset(.send)!)
    }()
    private lazy var messageTextField = {
        return UITextField.createTextField(text: "輸入訊息")
    }()
    private var viewModel: ChatroomViewModel = ChatroomViewModel()
//    private var dataSource: UITableViewDiffableDataSource<OneSection, ChatroomData>!
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
    // MARK: -
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
        viewModel.fetchConversation()
        viewModel.isLoading.bind { [weak self] isLoading in
            guard let self, let isLoading = isLoading else {
                return
            }
            DispatchQueue.main.async {
                if isLoading {
                    self.viewModel.fetchConversation()
                } else {
                    return
                }
            }
        }
    }
}
// MARK: -
extension ChatroomViewController {
//    private func configureDataSource() {
//        dataSource = UITableViewDiffableDataSource<OneSection, ChatroomData>(
//            tableView: tableView,
//            cellProvider: { tableView, indexPath, item in
//                let cell = tableView.dequeueReusableCell(
//                    withIdentifier: ChatroomTableViewCell.identifier,
//                    for: indexPath) as? ChatroomTableViewCell
//                guard let cell = cell else { return UITableViewCell() }
//                cell.personalImageView.image = UIImage.systemAsset(.personalPicture)
//                cell.nameLabel.text = item.chatroomChat.userId
//                cell.messageLabel.text = item.chatroomChat.content
//                return cell
//            }
//        )
//    }
}

// MARK: -
extension ChatroomViewController {
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(submitMessageButton)
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
}
