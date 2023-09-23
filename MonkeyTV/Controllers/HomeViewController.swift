//
//  HomeViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import FirebaseFirestore

class HomeViewController: BaseViewController {
    private lazy var tableView = {
        var tableView = UITableView()
        tableView.rowHeight = 260
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
    private var snapshots = [NSDiffableDataSourceSnapshot<OneSection, Show>]()
//    private var dataSources: [UICollectionViewDiffableDataSource<OneSection, Show>] = []
    private let dispatchSemaphore = DispatchSemaphore(value: 1)
    private let showCatalogArray = ShowCatalog.allCases.map { $0.rawValue }
    private var cacheDataDictionary = [Int: NSDiffableDataSourceSnapshot<OneSection, Show>]()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        updateTableViewDataSource()
        setUI()
    }

    // MARK: - Update TableView DataSource
    func updateTableViewDataSource() {
        tableViewDataSource =
        UITableViewDiffableDataSource<OneSection, String>(
            tableView: tableView) { tableView, indexPath, _ in
                let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: CollectionTableViewCell.identifier,
                    for: indexPath) as? CollectionTableViewCell
                guard let cell = cell else { return UITableViewCell() }
                cell.showVideoPlayerDelegate = self
                cell.titleLabel.text = self.showCatalogArray[indexPath.row]
                cell.catalogType = indexPath.row
                return cell
            }
        tableView.dataSource = tableViewDataSource
        tableViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, String>()
        tableViewSnapshot.appendSections([OneSection.main])
        tableViewSnapshot.appendItems(showCatalogArray, toSection: .main)
        tableViewDataSource.apply(tableViewSnapshot)
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
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
