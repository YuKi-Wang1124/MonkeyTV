//
//  FavoriteViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import WebKit

class FavoriteViewController: UIViewController, UITableViewDelegate {
    
    private lazy var tableView: UITableView = {
        return  CustomTableView(rowHeight: UITableView.automaticDimension,
                                separatorStyle: .none,
                                allowsSelection: true,
                                registerCells: [ShowTableViewCell.self])
    }()
    
    private var tableViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, ShowData>()
    private var tableViewDataSource: UITableViewDiffableDataSource<OneSection, ShowData>!
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        Task { await updateTableViewDataSource() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        setUI()
    }
    
    // MARK: - Update TableView DataSource
    
    func updateTableViewDataSource() async {
        tableViewDataSource =
        UITableViewDiffableDataSource<OneSection, ShowData>(
            tableView: tableView) { tableView, indexPath, itemIdentifier in
                
                let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: ShowTableViewCell.identifier,
                    for: indexPath) as? ShowTableViewCell
                guard let cell = cell else { return UITableViewCell() }
                
                cell.showImageView.loadImage(itemIdentifier.showImage)
                cell.showNameLabel.text = itemIdentifier.showName
                
                return cell
            }
        
        if var showArray = await FirestoreManager.fetchMyFavoriteShow(email: KeychainItem.currentEmail ) {
            print(showArray)
            showArray.remove(at: 0)
            tableView.dataSource = tableViewDataSource
            tableViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, ShowData>()
            tableViewSnapshot.appendSections([OneSection.main])
            tableViewSnapshot.appendItems(showArray, toSection: .main)
            await tableViewDataSource.apply(tableViewSnapshot)
        }
    }
    
    private func setUI() {
        view.addSubview(tableView)
        view.backgroundColor = .baseBackgroundColor
        tableView.backgroundColor = .baseBackgroundColor

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let itemIdentifier = tableViewDataSource.itemIdentifier(for: indexPath) else { return }
        
        YouTubeParameter.shared.playlistId = itemIdentifier.playlistId
        
        let playerViewController = PlayerViewController()
        playerViewController.modalPresentationStyle = .fullScreen
        playerViewController.playlistId = itemIdentifier.playlistId
        playerViewController.id = itemIdentifier.id
        playerViewController.showImage = itemIdentifier.showImage
        
        self.present(playerViewController, animated: true)
        
    }
}
