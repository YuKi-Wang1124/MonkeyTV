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
    
    //    let array: [String] = [String]()
    let array: [String] = ["無知","風雲變幻施耐庵唉西門吹雪呵呵噠","快看看","窿窿啦啦","一桿禽獸狙","合歡花","暴走大事件","非誠勿擾","呵呵呵"]
    var width: CGFloat = 0
    var height: CGFloat = 0
    // MARK: - Table View
    private var tableView: UITableView = {
        var tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
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
    private lazy var buttonsView = {
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
        setupButttons()
        setupSearchBar()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
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

    private func setupButttons() {

        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
            buttonsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        for index in 0 ..< array.count {
            let button = UIButton(type: .system)
            button.tag = 100 + index
            button.backgroundColor = UIColor.white
            button.addTarget(self, action: #selector(handleClick(_:)), for: .touchUpInside)
            button.setTitleColor(UIColor.darkGray, for: .normal)
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.cornerRadius = 5
            
            let length = array[index].getLabWidth(font: UIFont.systemFont(ofSize: 16), height: 13).width
            button.setTitle(array[index], for: .normal)
            button.frame = CGRect(x: 10 + width,
                                  y: height,
                                  width: length + 15,
                                  height: 30)
            
            if 10 + width + length + 15 > UIScreen.main.bounds.width {
                width = 0
                height = height + button.frame.size.height + 10
                button.frame = CGRect(x: 10 + width,
                                      y: height,
                                      width: length + 15,
                                      height: 30)
            }
            width = button.frame.size.width + button.frame.origin.x
            buttonsView.addSubview(button)
        }
    }
    @objc func handleClick(_ button: UIButton) {
        print("\(button.tag)")
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
        print(self.filterDataList)
    }
}

// MARK: - UI configuration
extension SearchViewController {
    private func setupUI() {
        view.addSubview(hiddenView)
        view.addSubview(tableView)
        hiddenView.isHidden = true
        tableView.isHidden = true
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

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let historyDataSource = StorageManager.shared.fetchSearchHistorys()
//        if let data = historyDataSource {
//            return data.count
//        } else {
//            return 0
//        }
        return 1
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
