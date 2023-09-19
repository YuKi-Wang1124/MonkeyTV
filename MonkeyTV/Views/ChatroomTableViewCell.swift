//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/18.
//
import UIKit
import FirebaseFirestore

class ChatroomTableViewCell: UITableViewCell {
    static let identifier = "\(ChatroomTableViewCell.self)"
    var personalImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    // MARK: - Setup Cell UI
    private func setupCellUI() {
        let screenWidth = UIScreen.main.bounds.width
        contentView.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        contentView.addSubview(personalImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            personalImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            personalImageView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor,
                                                        constant: -16),
            personalImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            personalImageView.heightAnchor.constraint(equalToConstant: 30),
            personalImageView.widthAnchor.constraint(equalToConstant: 30),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - ChatroomCellViewModel
class ChatroomViewModel {
    var isLoading: Observable<Bool> = Observable(false)
    private var listener: ListenerRegistration?
    private var snapshot = NSDiffableDataSourceSnapshot<OneSection, ChatroomData>()
    private var dataSource: UITableViewDiffableDataSource<OneSection, ChatroomData>!

    func dataSourcenApplySnapshot() {
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    deinit {
        listener?.remove()
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
                print(data["chatroomChat"].)

//                self?.snapshot.appendSections([OneSection.main])
//                self?.snapshot.appendItems([decodedObject])
            }
        }
    }
}
