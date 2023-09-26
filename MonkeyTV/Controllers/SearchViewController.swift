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
    
    private var filterDataList: [Show] = [Show]()
    private var searchedDataSource: [Show] = [Show]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        FirestoreManager.getAllShowsData(completion: { [weak self] showArrayData in
            guard let self = self else { return }
            self.searchedDataSource = showArrayData
//            print("showArray ======= \(self.searchedDataSource)")
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
        if let searchText = self.searchController.searchBar.text?.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines),
           searchText.isEmpty != true {
            filterDataSource(for: searchText)
        } else {
            return
        }
    }
    
    // 點擊searchBar上的取消按鈕
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 依個人需求決定如何實作
        // ...
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.resignFirstResponder()
    }
    
    // 過濾被搜陣列裡的資料
    func filterDataSource(for searchText: String) {
        self.filterDataList = searchedDataSource.filter({ (show) -> Bool in
            let showName = show.showName
            if showName.localizedCaseInsensitiveContains(searchText) {
                filterDataList.append(show)
                return true
            } else {
                return false
            }
        })
                    print("filterDataList ======= \(self.filterDataList)")

        //            if self.filterDataList.count > 0 {
        //                self.isShowSearchResult = true
        //                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.init(rawValue: 1)! // 顯示TableView的格線
        //            } else {
        //                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none // 移除TableView的格線
        //                // 可加入一個查找不到的資料的label來告知使用者查不到資料...
        //                // ...
        //            }
        //
        //            self.tableView.reloadData()
        //        }
    }
}
