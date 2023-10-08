//
//  FavoriteViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import WebKit

class FavoriteViewController: UIViewController, UITableViewDelegate {
  
    private var tableView: UITableView = {
        var tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.register(ShowTableViewCell.self,
                           forCellReuseIdentifier:
                            ShowTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var tableViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, MyShow>()
    private var tableViewDataSource: UITableViewDiffableDataSource<OneSection, MyShow>!
    
    override func viewWillAppear(_ animated: Bool) {
        updateTableViewDataSource()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        setUI()
    }
    
    // MARK: - Update TableView DataSource
    
    func updateTableViewDataSource() {
        tableViewDataSource =
        UITableViewDiffableDataSource<OneSection, MyShow>(
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
        if let showArray = StorageManager.shared.fetchSearchMyShows() {
            print(showArray)
            
            tableView.dataSource = tableViewDataSource
            tableViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, MyShow>()
            tableViewSnapshot.appendSections([OneSection.main])
            tableViewSnapshot.appendItems(showArray, toSection: .main)
            tableViewDataSource.apply(tableViewSnapshot)
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let itemIdentifier = tableViewDataSource.itemIdentifier(for: indexPath) else { return }
        
        YouTubeParameter.shared.playlistId = itemIdentifier.playlistId!
        
        let playerViewController = PlayerViewController()
        playerViewController.modalPresentationStyle = .fullScreen
        playerViewController.playlistId = itemIdentifier.playlistId!
        playerViewController.id = itemIdentifier.id!
        playerViewController.showImage = itemIdentifier.showImage!
        
        self.present(playerViewController, animated: true)
        
    }
}
