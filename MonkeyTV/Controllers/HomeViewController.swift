//
//  HomeViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import FSPagerView
import FirebaseFirestore
import NVActivityIndicatorView

class HomeViewController: BaseViewController {
    private lazy var tableView = {
        var tableView = UITableView()
        tableView.rowHeight = 250
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
    
    private let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: 0, y: 0, width: 80, height: 80),
        type: .ballSpinFadeLoader, color: UIColor.mainColor, padding: 10)
    
    private var tableViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, String>()
    private var tableViewDataSource: UITableViewDiffableDataSource<OneSection, String>!
    private let showCatalogArray = ShowCatalog.allCases.map { $0.rawValue }
    
    override func viewWillAppear(_ animated: Bool) {
        Task { await showUserName() }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableViewDataSource()
        setupTableViewUI()
    }
    
    private func showUserName() async {
        if KeychainItem.currentEmail.isEmpty {
            self.navigationItem.title = "MonkeyTV"
            return
        }
        
        if let userInfo = await UserInfoManager.userInfo() {
            self.navigationItem.title = userInfo.userName + "，歡迎您"
        }
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
                        for: indexPath) as? HomeAnimationTableViewCell
                    guard let cell = cell else { return UITableViewCell() }
                    
                    cell.showVideoPlayerDelegate = self
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
                    cell.dataFetchCompletion = { [weak self] in
                        self?.activityIndicatorView.stopAnimating()
                    }
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
    private func setupTableViewUI() {
        view.addSubview(tableView)
        view.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        tableView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = view.center
        activityIndicatorView.startAnimating()
        activityIndicatorView.layer.cornerRadius = 10
        activityIndicatorView.backgroundColor = UIColor.setColor(
            lightColor: UIColor(white: 0.5, alpha: 0.4),
            darkColor: UIColor(white: 0.1, alpha: 0.5))
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - ShowVideoPlayerDelegate
extension HomeViewController: ShowVideoPlayerDelegate {
    
    func showVideoPlayer(showName: String, playlistId: String, id: String, showImage: String) {
        
        let playerViewController = PlayerViewController()
        playerViewController.modalPresentationStyle = .fullScreen
        playerViewController.playlistId = playlistId
        playerViewController.id = id
        playerViewController.showImage = showImage
        self.present(playerViewController, animated: true)
    }
    
}
