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
    private var listener: ListenerRegistration?
    var snapshot = NSDiffableDataSourceSnapshot<OneSection, ChatroomData>()
    var dataSource: UITableViewDiffableDataSource<OneSection, ChatroomData>!

    deinit {
        listener?.remove()
    }
    func configureDataSource(tableView: UITableView) {
        dataSource = UITableViewDiffableDataSource<OneSection, ChatroomData>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ChatroomTableViewCell.identifier,
                    for: indexPath) as? ChatroomTableViewCell
                guard let cell = cell else { return UITableViewCell() }
                cell.personalImageView.image = UIImage.systemAsset(.personalPicture)
                cell.nameLabel.text = item.chatroomChat.userId
                cell.messageLabel.text = item.chatroomChat.content
                return cell
            }
        )
    }
    func fetchConversation() {
        if isLoading.value ?? true {
            return
        }
        isLoading.value = true
        listener = FirestoreManageer.chatroomCollection.addSnapshotListener { [weak self] querySnapshot, error in
            self?.isLoading.value = false
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            for document in documents {
                let data = document.data()
                print(data["id"] as? String as Any)
                print(data["videoId"] as? String as Any)
                let dict = data["chatroomChat"] as? [String: Any]
                if let dict = dict {
                    if let createdTime = dict["createdTime"] as? Timestamp {
                    let object = ChatroomData(
                        chatroomChat: ChatroomChat(chatId: dict["chatId"] as? String,
                                                   content: dict["content"] as? String,
                                                   contentType: dict["contentType"] as? Int,
                                                   createdTime: createdTime.dateValue(),
                                                   userId: dict["userId"] as? String),
                        videoId: data["videoId"] as? String ?? "",
                        id: data["id"] as? String ?? "")
                        print(object)
                        guard let self = self else { return }
                        if !(self.snapshot.sectionIdentifiers.contains(OneSection.main)) {
                            self.snapshot.appendSections([OneSection.main])
                        }
//                        if self.snapshot.itemIdentifiers.isEmpty == false {
//                            let items = snapshot.itemIdentifiers(inSection: .main)
//                            snapshot.deleteItems(items)
//                            snapshot.appendItems([object] + items, toSection: .main)
//                        } else {
                            self.snapshot.appendItems([object], toSection: .main)
                            self.dataSource.apply(self.snapshot)
                            print(self.snapshot as Any)
//                        }
                    }
                }
            }
        }
    }
}
