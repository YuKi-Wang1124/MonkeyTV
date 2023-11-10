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


class HomeViewController: UIViewController {
    
    private lazy var tableView: CustomTableView = {
        return  CustomTableView(
            rowHeight: 250,
            separatorStyle: .none,
            allowsSelection: false,
            registerCells: [CollectionTableViewCell.self,
                            HomeAnimationTableViewCell.self])
    }()
    
    private let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: 0, y: 0, width: 60, height: 60),
        type: .lineSpinFadeLoader, color: UIColor.mainColor, padding: 10)
    
    private var tableViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, String>()
    private var tableViewDataSource: UITableViewDiffableDataSource<OneSection, String>!
    private let showCatalogArray = ShowCatalog.allCases.map { $0.rawValue }
    
    private lazy var copyRightTextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = UIColor.setColor(
            lightColor: UIColor(white: 1, alpha: 0.9),
            darkColor: UIColor(white: 0.1, alpha: 1))
        textView.text = Constant.COPYRIGHT_TEXT
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = .darkAndWhite
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableViewDataSource()
        setupTableViewUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await showUserName() }
    }
    
    private func showUserName() async {
        if KeychainItem.currentEmail.isEmpty {
            self.navigationItem.title = Constant.monkeyTV
            return
        }
        
        if let userInfo = await UserInfoManager.userInfo() {
            self.navigationItem.title = userInfo.userName + Constant.welcome
        }
    }
    
    // MARK: - Update TableView DataSource
    
    private func updateTableViewDataSource() {
        tableViewDataSource =
        UITableViewDiffableDataSource<OneSection, String>(
            tableView: tableView) { tableView, indexPath, _ in
                if indexPath.row == 0 {
                    let cell: HomeAnimationTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.showVideoPlayerDelegate = self
                    return cell
                } else {
                    let index = indexPath.row - 1
                    let cell: CollectionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                    // TODO: 檢查 indexPath.row 有沒有這個 array
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
        view.addSubview(activityIndicatorView)
        view.backgroundColor = .baseBackgroundColor
        tableView.backgroundColor = .baseBackgroundColor
        activityIndicatorView.center = view.center
        activityIndicatorView.startAnimating()
        activityIndicatorView.layer.cornerRadius = 10
        activityIndicatorView.backgroundColor = UIColor.setColor(
            lightColor: UIColor(white: 1, alpha: 0.4),
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
