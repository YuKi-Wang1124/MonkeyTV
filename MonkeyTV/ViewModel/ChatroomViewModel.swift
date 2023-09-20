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
    func fetchConversation(currentTime: Date) {
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
            var newItems = [ChatroomData]()
            for document in documents {
                let data = document.data()
                let dict = data["chatroomChat"] as? [String: Any]
                if let dict = dict,
                   let createdTime = dict["createdTime"] as? Timestamp,
                   createdTime.dateValue() >= currentTime {
                    let object = ChatroomData(
                        chatroomChat: ChatroomChat(
                            chatId: dict["chatId"] as? String,
                            content: dict["content"] as? String,
                            contentType: dict["contentType"] as? Int,
                            createdTime: createdTime.dateValue(),
                            userId: dict["userId"] as? String),
                        videoId: data["videoId"] as? String ?? "",
                        id: data["id"] as? String ?? "")
                    if !(self?.snapshot.itemIdentifiers.contains(object))! {
                        newItems.append(object)
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
