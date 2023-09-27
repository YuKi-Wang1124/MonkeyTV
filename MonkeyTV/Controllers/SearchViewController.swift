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
//        tableView.rowHeight = 50
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


// MARK: -
//class QYPAdaptiveButton: UIView {
//    weak var delegate:QYPAdaptiveButtonDelegate?
//    /// 中間button,記錄選中狀態
//    var tempButton:UIButton?
//    /// 按鈕的button中文字數組
//    var titleArray = [String]()
//    /// 正常時候顯示的字體大小
//    var normal = CGFloat()
//    /// 放大時候顯示的字體大小
//    var bigger = CGFloat()
//    /// 設置每一個按鈕的高度
//    var heightBtn = CGFloat()
//
//    class func creat(frame:CGRect,titleArr:[String],normal:CGFloat = 12,bigger:CGFloat = 15,heightBtn:CGFloat = 30) -> QYPAdaptiveButton{
//        let v = QYPAdaptiveButton(frame: frame)
//        v.titleArray = titleArr
//        v.normal = normal
//        v.bigger = bigger
//        v.heightBtn = heightBtn
//        v.setupUI()
//        return v
//    }
//}
//extension QYPAdaptiveButton {
//    fileprivate func setupUI(){
//        // 定義常量 btn的height + 頂部空隙(沒增加一行的高度)
//        let rowHeight:CGFloat = heightBtn + 5
//        // 定義一個變量,用於記錄每一個btn的x值
//        let btnX:CGFloat = CGFloat(gap)
//        let btnY:CGFloat = 0
//        var x:CGFloat = btnX
//        var y:CGFloat = btnY
//        // 定義一個屬性,記錄已經是第幾行,然後對應的背景view也要需要增加多高
//        var index = 0
//
//        // 創建證件類型選擇按鈕
//        for i in 0..<titleArray.count {
//            let size = titleArray[i].getLabWidth(font: UIFont.systemFont(ofSize: bigger), height: heightBtn)
//            if x + size.width > SCREEN_WIDTH {
//                index += 1
//                x = CGFloat(gap)
//                y += rowHeight
//            }
//            let rect = CGRect(x: x, y: y, width: size.width, height: heightBtn)
//            x += size.width + CGFloat(gap)
//            let btn = UIButton()
//            //2:設置按鈕的bg圖片與普通圖片
//
//            btn.frame = rect
//            btn.setTitle(titleArray[i], for: .normal)
//            btn.setTitleColor(UIColor.gray , for: .normal)
//            btn.setTitle(titleArray[i], for: .selected)
//            btn.setTitleColor(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), for: .selected)
//            btn.titleLabel?.font = UIFont.systemFont(ofSize: normal)
//            btn.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:0.5)
//            btn.layer.cornerRadius = 8
//            btn.tag = 100 + i
//            btn.addTarget(target, action: #selector(chooseOCR), for: .touchUpInside)
//
//            btn.titleLabel?.font = UIFont.systemFont(ofSize: normal)
//            if i == 0 {
//                btn.titleLabel?.font = UIFont.systemFont(ofSize: bigger)
//                btn.isSelected = true
//                tempButton = btn
//            }
//            self.addSubview(btn)
//        }
//        // 重新設置self.height的高度
//        self.height += CGFloat(index) * rowHeight + rowHeight
//    }
//    /// 點擊某一個button的時候，通過tag值獲取到了對應的button，然後做出對應的響應
//    @objc func chooseOCR(btn:UIButton){
//        tempButton?.titleLabel?.font = UIFont.systemFont(ofSize: normal)
//        tempButton?.isSelected = false
//        tempButton = btn
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: bigger)
//        btn.isSelected = true
//        if delegate != nil {
//            delegate?.searchHistory(index:btn.tag - 100)
//        }
//
//    }
//}
