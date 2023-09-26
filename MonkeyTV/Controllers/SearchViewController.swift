//
//  ViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import youtube_ios_player_helper

class SearchViewController: UIViewController {
    
    private let searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "請輸入片名"
        return searchController
    }()
    // MARK: - Table View
    private var tableView: UITableView = {
        var tableView = UITableView()
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(SearchHistoryTableViewCell.self,
                           forCellReuseIdentifier:
                            SearchHistoryTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private var hiddenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // MARK: -
    private var filterDataList: [Show] = [Show]()
    private var searchedDataSource: [Show] = [Show]()
    private var historyDataSource = StorageManager.shared.fetchSearchHistorys()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() 
        setupSearchBar()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false

        tableView.delegate = self
        tableView.dataSource = self
        FirestoreManager.getAllShowsData(completion: { [weak self] showArrayData in
            guard let self = self else { return }
            self.searchedDataSource = showArrayData
        })
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }

}

// MARK: -
extension SearchViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines),
           searchText.isEmpty != true {
            filterDataSource(for: searchText)
        } else {
            return
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchController.searchBar.text,
           searchText.isEmpty != true {
            StorageManager.shared.createSearchHistoryObject(showName: searchText)
            if let data = historyDataSource {
            }
        } else {
            return
        }
        self.searchController.searchBar.resignFirstResponder()
    }
    private func filterDataSource(for searchText: String) {
        self.filterDataList = searchedDataSource.filter({ (show) -> Bool in
            let showName = show.showName
            if showName.localizedCaseInsensitiveContains(searchText) {
                filterDataList.append(show)
                return true
            } else {
                return false
            }
        })
    }
}

// MARK: - UI configuration
extension SearchViewController {
    private func setupUI() {
        view.addSubview(hiddenView)
        view.addSubview(tableView)
        hiddenView.isHidden = true
        NSLayoutConstraint.activate([
            hiddenView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hiddenView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hiddenView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hiddenView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let historyDataSource = StorageManager.shared.fetchSearchHistorys()
        if let data = historyDataSource {
            return data.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchHistoryTableViewCell.identifier,
                                                 for: indexPath) as? SearchHistoryTableViewCell
        guard let cell = cell else { return UITableViewCell() }
        if let data = historyDataSource {
            cell.historyNameLabel.text = data[indexPath.row].showName
        }
        return cell
    }
}
