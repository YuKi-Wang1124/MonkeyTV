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
        tableView.register(HomeAnimationTableViewCell.self,
                           forCellReuseIdentifier:
                            HomeAnimationTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var tableViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, String>()
    private var tableViewDataSource: UITableViewDiffableDataSource<OneSection, String>!
    private let showCatalogArray = ShowCatalog.allCases.map { $0.rawValue }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableViewDataSource()
        setUI()
    }
    // MARK: - Update TableView DataSource
    func updateTableViewDataSource() {
        tableViewDataSource =
        UITableViewDiffableDataSource<OneSection, String>(
            tableView: tableView) { tableView, indexPath, _ in
                if indexPath.row == 0 {
                    let cell =
                    tableView.dequeueReusableCell(
                        withIdentifier: HomeAnimationTableViewCell.identifier,
                        for: indexPath) as? CollectionTableViewCell
                    guard let cell = cell else { return UITableViewCell() }
                    return cell
                } else {
                    let index = indexPath.row - 1
                    let cell =
                    tableView.dequeueReusableCell(
                        withIdentifier: CollectionTableViewCell.identifier,
                        for: indexPath) as? CollectionTableViewCell
                    guard let cell = cell else { return UITableViewCell() }
                    cell.titleLabel.text = self.showCatalogArray[indexPath.row]
                    cell.catalogType = index
                    cell.showVideoPlayerDelegate = self
                    return cell
                }
            }
        tableView.dataSource = tableViewDataSource
        tableViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, String>()
        tableViewSnapshot.appendSections([OneSection.main])
        tableViewSnapshot.appendItems(showCatalogArray, toSection: .main)
        tableViewDataSource.apply(tableViewSnapshot)
    }
}

// MARK: - UI configuration
extension HomeViewController {
    private func setUI() {
        view.addSubview(tableView)
        view.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        tableView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: -
extension HomeViewController: ShowVideoPlayerDelegate {
   
    func showVideoPlayer(showName: String, playlistId: String, id: String, showImage: String) {
        
        let playerViewController = PlayerViewController()
        playerViewController.modalPresentationStyle = .fullScreen
        playerViewController.playlistId = playlistId
        playerViewController.id = id
        playerViewController.showName = showName
        playerViewController.showImage = showImage
        self.present(playerViewController, animated: true)
    }
}
