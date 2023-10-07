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
        label.text = "即時聊天室"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var submitMessageButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.send),
            color: UIColor.setColor(lightColor: .darkGray, darkColor: .white),
            cornerRadius: 0, backgroundColor: .systemGray4)
    }()
    private lazy var messageTextField = {
        return UITextField.createTextField(
            text: "    輸入即時聊天訊息",
            backgroundColor: UIColor.setColor(lightColor: .white, darkColor: .systemGray5))
    }()
    private var viewModel: ChatroomViewModel = ChatroomViewModel()
    private var userId: String = ""
    private var userName: String = ""
    private var userImage: String = ""
    var videoId: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        Task { await showUserName() }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = viewModel.dataSource
        viewModel.configureDataSource(tableView: self.tableView)
        bindingViewModel()
        setupUI()
        submitMessageButton.addTarget(self, action: #selector(submitMessage), for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        PlayerViewController.chatroonIsShow = false
    }

    func showUserName() async {
        if KeychainItem.currentEmail.isEmpty {
            userId = "匿名"
            userName = "匿名"
            return
        }
        if let userInfo = await UserInfoManager.userInfo() {
            userId = userInfo.email
            userName = userInfo.userName
            userImage = userInfo.userImage
        }
    }
    // MARK: - Submit Message To DB
    @objc func submitMessage() {
        if let text = messageTextField.text, text.isEmpty == false {
            let id = FirestoreManager.chatroom.document().documentID
            let data: [String: Any] =
            ["chatroomChat":
                ["chatId": UUID().uuidString, "content": text, "contentType": 0,
                 "createdTime": FirebaseFirestore.Timestamp(),
                 "userId": userId,
                 "userName": userName,
                 "userImage": userImage
                ] as [String: Any],
             "videoId": videoId, "id": id]
            FirestoreManager.chatroom.document(id).setData(data) { error in
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
        view.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        tableView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)

        view.addSubview(submitMessageButton)
        view.addSubview(tableView)
        view.addSubview(submitMessageButton)
        view.addSubview(messageTextField)
        view.addSubview(chatroomTitleLabel)

        NSLayoutConstraint.activate([
            chatroomTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 26),
            chatroomTitleLabel.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
          
            chatroomTitleLabel.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            
            messageTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            messageTextField.trailingAnchor.constraint(equalTo: submitMessageButton.leadingAnchor, constant: 0),
            messageTextField.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            messageTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            submitMessageButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            submitMessageButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            submitMessageButton.heightAnchor.constraint(equalTo: messageTextField.heightAnchor),
            messageTextField.widthAnchor.constraint(equalTo: submitMessageButton.widthAnchor, multiplier: 7)
        ])
    }
}


extension ChatroomViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if let chatroomData = viewModel.dataSource.itemIdentifier(for: indexPath) {
              let selectedUserName = chatroomData.chatroomChat.userId
            print("所选行的用户名：\(String(describing: selectedUserName))")
              
          }
    }
    
}
