//
//  HomeViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import FirebaseFirestore

class HomeViewController: BaseViewController, UICollectionViewDelegate {
    private lazy var tableView = {
        var tableView = UITableView()
        tableView.rowHeight = 300
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(CollectionTableViewCell.self,
                           forCellReuseIdentifier:
                            CollectionTableViewCell.identifier)
        tableView.register(VideoTableViewCell.self,
                           forCellReuseIdentifier:
                            VideoTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private var tableViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, String>()
    private var tableViewDataSource: UITableViewDiffableDataSource<OneSection, String>!
    private var collectionViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, Show>()
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<OneSection, Show>!
    private let dispatchSemaphore = DispatchSemaphore(value: 1)
    private let showCatalogArray = ShowCatalog.allCases.map { $0.rawValue }
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getShowData()
        updateTableViewDataSource()
        setUI()
    }
    // MARK: - Update TableView DataSource
    func updateTableViewDataSource() {
        tableViewDataSource =
        UITableViewDiffableDataSource<OneSection, String>(
            tableView: tableView) { tableView, indexPath, itemIdentifier in
                let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: CollectionTableViewCell.identifier,
                    for: indexPath) as? CollectionTableViewCell
                guard let cell = cell else { return UITableViewCell() }
                cell.delegate = self
                self.configureCollectionViewDataSource(collectionView: cell.collectionView)
                cell.collectionView.dataSource = self.collectionViewDataSource
                self.collectionViewDataSource.apply(self.collectionViewSnapshot)
                cell.titleLabel.text = self.showCatalogArray[indexPath.row]
                return cell
            }
        tableView.dataSource = tableViewDataSource
        tableViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, String>()
        tableViewSnapshot.appendSections([OneSection.main])
        tableViewSnapshot.appendItems(showCatalogArray, toSection: .main)
        tableViewDataSource.apply(tableViewSnapshot)
    }
    // MARK: - getDanMuData
    private func getShowData() {
        collectionViewSnapshot.appendSections([OneSection.main])
        FirestoreManageer.show.getDocuments { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                        let decodedObject = try JSONDecoder().decode(Show.self, from: jsonData)
                        print(decodedObject)
                        let show = Show(type: decodedObject.type,
                                        playlistId: decodedObject.playlistId,
                                        image: decodedObject.image,
                                        id: decodedObject.id,
                                        showName: decodedObject.showName)
                        DispatchQueue.main.async {
                            self.collectionViewSnapshot.appendItems([show], toSection: OneSection.main)
                        }
                    } catch {
                        print("\(error)")
                    }
                }
                self.collectionViewDataSource.apply(self.collectionViewSnapshot)
            }
        }
    }
}
extension HomeViewController: ShowVideoPlayerDelegate {
    func showVideoPlayer() {
        VideoLauncher.shared.videoId = "FjJtmJteK58"
        VideoLauncher.shared.showVideoPlayer()
    }
}

// MARK: - UI configuration
extension HomeViewController {
    private func setUI() {
        view.backgroundColor = UIColor.white
        tableView.backgroundColor = UIColor.white
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: -
extension HomeViewController {
    func configureCollectionViewDataSource(collectionView: UICollectionView) {
        self.collectionViewDataSource =
        UICollectionViewDiffableDataSource<OneSection, Show>(
            collectionView: collectionView,
            cellProvider: { (colloctionvVew, indexPath, itemIdentifier) -> UICollectionViewCell? in
                let cell = colloctionvVew.dequeueReusableCell(
                    withReuseIdentifier: VideoCollectionViewCell.identifier,
                    for: indexPath) as? VideoCollectionViewCell
                cell?.label.text = itemIdentifier.showName
                UIImage.displayThumbnailImage(from: itemIdentifier.image, completion: { image in
                    cell?.coverImageView.image = image
                })
                return cell
            })
    }
}
