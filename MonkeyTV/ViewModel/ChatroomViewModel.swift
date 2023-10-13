//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/19.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class ChatroomViewModel {
    var isLoading: Observable<Bool> = Observable(false)
    var snapshot = NSDiffableDataSourceSnapshot<OneSection, ChatroomData>()
    var dataSource: UITableViewDiffableDataSource<OneSection, ChatroomData>!
    private var listener: ListenerRegistration?
    private var blocklistListener: ListenerRegistration?
    private var blocklistArray = [String]()

    deinit {
        listener?.remove()
        blocklistListener?.remove()
    }
    func configureDataSource(tableView: UITableView) {
        dataSource = UITableViewDiffableDataSource<OneSection, ChatroomData>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ChatroomTableViewCell.identifier,
                    for: indexPath) as? ChatroomTableViewCell
                guard let cell = cell else { return UITableViewCell() }
                cell.personalImageView.loadImage(item.chatroomChat.userImage,
                                                 placeHolder: UIImage.systemAsset(.personalPicture))
                cell.nameLabel.text = item.chatroomChat.userName
                cell.messageLabel.text = item.chatroomChat.content
                return cell
            }
        )
    }
    
    func fetchConversation(currentTime: Date) {
        
        if isLoading.value ?? true {
            return
        }
        isLoading.value = true
        
        blocklistListener = FirestoreManager.userBlockList.document(
            KeychainItem.currentEmail).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot else {
                print("Document snapshot is nil")
                return
            }
            
            if document.exists {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data()!)
                    let decodedObject = try JSONDecoder().decode(BlocklistData.self, from: jsonData)
                    blocklistArray = decodedObject.blocklist
                } catch {
                    print("Error decoding data: \(error.localizedDescription)")
                }
            } else {
                print("Document does not exist")
            }
        }

        listener = FirestoreManager.chatroom.addSnapshotListener { [weak self] querySnapshot, error in
            self?.isLoading.value = false
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            var newItems = [ChatroomData]()
            for document in documents {
                let data = document.data()
                let dict = data["chatroomChat"] as? [String: Any]
                if let dict = dict,
                    let createdTime = dict["createdTime"] as? Timestamp,
                   let chatId = dict["chatId"] as? String,
                   let content = dict["content"] as? String,
                   let contentType = dict["contentType"] as? Int,
                   let userId = dict["userId"] as? String,
                   let userName = dict["userName"] as? String,
                   let userImage = dict["userImage"] as? String,
                   let videoId = data["videoId"] as? String,
                   let id = data["id"] as? String,
                   createdTime.dateValue() >= currentTime {
                    
                    let isBlocked = self?.blocklistArray.contains(userId) ?? false

                    if !isBlocked {
                        
                        let object = ChatroomData(
                            chatroomChat: ChatroomChat(
                                chatId: chatId, content: content, contentType: contentType,
                                createdTime: createdTime.dateValue(), userId: userId, userName: userName, userImage: userImage),
                            videoId: videoId, id: id)
                        if !(self?.snapshot.itemIdentifiers.contains(object))! {
                            newItems.append(object)
                        }
                    }
                }
            }
            guard let self = self else { return }
            if !(self.snapshot.sectionIdentifiers.contains(OneSection.main)) {
                self.snapshot.appendSections([OneSection.main])
            }
            self.snapshot.appendItems(newItems, toSection: .main)
            self.dataSource.apply(self.snapshot)
        }
    }
}

struct BlocklistData: Codable {
    let blocklist: [String]
}
