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
        tableView.register(VideoAnimationTableViewCell.self,
                           forCellReuseIdentifier:
                            VideoAnimationTableViewCell.identifier)
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
//            func getVideoCover(request: Request) {
                let decoder = JSONDecoder()
        HTTPClientManager.shared.request(YoutubeRequest.playlistItems, completion: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let data):
                        do {
                            let info = try decoder.decode(PlayerlistResponse.self, from: data)
//                            info.items.forEach({
                                print(info)
//                            })
                        } catch {
                            print(Result<Any>.failure(error))
                        }
                    case .failure(let error):
                        print(Result<Any>.failure(error))
                    }
                })
//            }
    }
    // MARK: - Update TableView DataSource
    func updateTableViewDataSource() {
        tableViewDataSource =
        UITableViewDiffableDataSource<OneSection, String>(
            tableView: tableView) { tableView, indexPath, _ in
                if indexPath.row == 0 {
                    let cell =
                    tableView.dequeueReusableCell(
                        withIdentifier: VideoAnimationTableViewCell.identifier,
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
    func showVideoPlayer() {
        let playerVC = PlayerViewController()
        playerVC.modalPresentationStyle = .fullScreen
        self.present(playerVC, animated: true)
    }
}
