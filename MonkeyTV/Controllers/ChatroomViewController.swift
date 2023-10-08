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
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.textAlignment = .left
        label.text = "即時聊天室"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let blocklistBackgroundView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let blocklistView = {
        let view = UIView()
        view.backgroundColor = UIColor.setColor(lightColor: UIColor.white,
                                                darkColor: UIColor(white: 0.1, alpha: 1))
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var showNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var blockUserNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .black, darkColor: .white)
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var submitMessageButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.paperplane),
            color: UIColor.setColor(lightColor: .darkGray, darkColor: .white),
            cornerRadius: 0, backgroundColor: .systemGray4)
    }()
    
    private lazy var closeButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.xmark, configuration: UIImage.smallSymbolConfig),
            color: UIColor.lightGray,
            cornerRadius: 0, backgroundColor: .clear)
    }()
    
    private lazy var closeBlocklistViewＢutton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.xmark, configuration: UIImage.smallSymbolConfig),
            color: UIColor.lightGray,
            cornerRadius: 0, backgroundColor: .clear)
    }()
    
    private lazy var blockButton = {
        let button = UIButton.createPlayerButton(
            image: UIImage.systemAsset(.nosign, configuration: UIImage.smallSymbolConfig),
            color: UIColor.setColor(lightColor: .black, darkColor: .white),
            cornerRadius: 0, backgroundColor: UIColor.clear)
        button.setTitle("  封鎖此用戶", for: .normal)
        button.setTitleColor(UIColor.setColor(lightColor: .black, darkColor: .white), for: .normal)
        return button
    }()
    
    private lazy var reportButton = {
        let button = UIButton.createPlayerButton(
            image: UIImage.systemAsset(.flag, configuration: UIImage.smallSymbolConfig),
            color: UIColor.setColor(lightColor: .black, darkColor: .white),
            cornerRadius: 0, backgroundColor: UIColor.clear)
        button.setTitle("  檢舉此留言", for: .normal)
        button.setTitleColor(UIColor.setColor(lightColor: .black, darkColor: .white), for: .normal)
        return button
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
    private var blockUserId: String = ""
//    private var blockUserName: String = ""
    private var reportUserContent: String = ""
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
        buttonAddTarget()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        PlayerViewController.chatroonIsShow = false
    }
    
    // MARK: -

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
    @objc func closeBlocklistView() {

        blocklistBackgroundView.isHidden = true
    }
    
    @objc func closeChatroomViewController() {
        dismiss(animated: true)
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
extension ChatroomViewController {
    
    // MARK: - buttonAddTarget
    private func buttonAddTarget() {
        submitMessageButton.addTarget(self, action: #selector(submitMessage), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeChatroomViewController), for: .touchUpInside)
        closeBlocklistViewＢutton.addTarget(self, action: #selector(closeBlocklistView), for: .touchUpInside)
        blockButton.addTarget(self, action: #selector(blockUser), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(report), for: .touchUpInside)
    }
    
    @objc func blockUser() {
        let alertController = UIAlertController(
            title: "是否要封鎖這位使用者？",
            message: "封鎖這位使用者後，您和對方將再也無法看到彼此的留言。",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "封鎖", style: .default) { _ in
            DispatchQueue.main.async {
                FirestoreManager.userBlock(userId: KeychainItem.currentEmail, blockUserId: self.blockUserId)
            }
            self.blocklistBackgroundView.isHidden = true
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            self.blocklistBackgroundView.isHidden = true
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func report() {
        let alertController = UIAlertController(
            title: "是否要檢舉此留言？",
            message: "我們將盡快審核您的檢舉，留言違反法規者，將通報當地執法機關，若有緊急情況，請您立即通知執法部門。",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "檢舉", style: .default) { _ in
            if let textField = alertController.textFields?.first, let reason = textField.text {
                FirestoreManager.report(userId: KeychainItem.currentEmail,
                                        reportId: self.blockUserId, reason: reason, message: self.reportUserContent)
                self.blocklistBackgroundView.isHidden = true
            }
        }

        alertController.addTextField { (textField) in
            textField.placeholder = "輸入檢舉原因"
            textField.text = ""
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            self.blocklistBackgroundView.isHidden = true
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        tableView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        showNameLabel.sizeToFit()
        blockUserNameLabel.sizeToFit()
        blocklistBackgroundView.isHidden = true
        view.addSubview(showNameLabel)
        view.addSubview(submitMessageButton)
        view.addSubview(tableView)
        view.addSubview(closeButton)
        view.addSubview(messageTextField)
        view.addSubview(chatroomTitleLabel)
        view.addSubview(blocklistBackgroundView)
        blocklistBackgroundView.addSubview(blocklistView)
        blocklistBackgroundView.addSubview(closeBlocklistViewＢutton)
        blocklistBackgroundView.addSubview(blockUserNameLabel)
        blocklistBackgroundView.addSubview(blockButton)
        blocklistBackgroundView.addSubview(reportButton)

        NSLayoutConstraint.activate([
            chatroomTitleLabel.topAnchor.constraint(equalTo: showNameLabel.bottomAnchor, constant: 0),
            chatroomTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            chatroomTitleLabel.trailingAnchor.constraint(
                equalTo: closeButton.leadingAnchor, constant: -16),
            
            showNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            showNameLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: 0),
            showNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            
            closeButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            closeButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: chatroomTitleLabel.bottomAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
        
            messageTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            messageTextField.trailingAnchor.constraint(equalTo: submitMessageButton.leadingAnchor, constant: 0),
            messageTextField.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            messageTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            submitMessageButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            submitMessageButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            submitMessageButton.heightAnchor.constraint(equalTo: messageTextField.heightAnchor),
            messageTextField.widthAnchor.constraint(equalTo: submitMessageButton.widthAnchor, multiplier: 7)
        ])
        
        NSLayoutConstraint.activate([
            
            blocklistBackgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            blocklistBackgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            blocklistBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            blocklistBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blocklistView.leadingAnchor.constraint(equalTo: blocklistBackgroundView.leadingAnchor, constant: 32),
            blocklistView.trailingAnchor.constraint(equalTo: blocklistBackgroundView.trailingAnchor, constant: -32),
            blocklistView.bottomAnchor.constraint(equalTo: blocklistBackgroundView.bottomAnchor, constant: -64),
            blocklistView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/3),

            closeBlocklistViewＢutton.trailingAnchor.constraint(
                equalTo: blocklistView.trailingAnchor, constant: -8),
            closeBlocklistViewＢutton.topAnchor.constraint(
                equalTo: blocklistView.topAnchor, constant: 8),
            closeBlocklistViewＢutton.heightAnchor.constraint(equalToConstant: 30),
            closeBlocklistViewＢutton.widthAnchor.constraint(equalToConstant: 30),
            
            blockUserNameLabel.leadingAnchor.constraint(equalTo: blocklistView.leadingAnchor, constant: 16),
            blockUserNameLabel.trailingAnchor.constraint(equalTo: closeBlocklistViewＢutton.leadingAnchor, constant: -4),
            blockUserNameLabel.topAnchor.constraint(equalTo: blocklistView.topAnchor, constant: 16),
            
            blockButton.leadingAnchor.constraint(equalTo: blocklistView.leadingAnchor, constant: 16),
            blockButton.bottomAnchor.constraint(equalTo: reportButton.topAnchor, constant: -32),
                        
            reportButton.leadingAnchor.constraint(equalTo: blocklistView.leadingAnchor, constant: 16),
            reportButton.bottomAnchor.constraint(equalTo: blocklistView.bottomAnchor, constant: -32)
        ])
    }
}

extension ChatroomViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let chatroomData = viewModel.dataSource.itemIdentifier(for: indexPath),
           let userid = chatroomData.chatroomChat.userId,
           let name = chatroomData.chatroomChat.userName,
           let content = chatroomData.chatroomChat.content {
            if userid == KeychainItem.currentEmail {
                return
            }
            blockUserNameLabel.text = "\(name)\n留言：\(content)"
            blockUserId = userid
            reportUserContent = content
            blocklistBackgroundView.isHidden = false
        }
    }
}
