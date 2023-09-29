//
//  ViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import youtube_ios_player_helper
import CoreData

class SearchViewController: UIViewController {
    
    private var tapGesture: UITapGestureRecognizer?
    
    private let searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "請輸入片名"
        return searchController
    }()
    
    private lazy var cleanHistoryButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.trash, configuration: UIImage.symbolConfig),
            color: UIColor.setColor(lightColor: .darkGray, darkColor: .white),
            cornerRadius: 30,
            backgroundColor: UIColor.clear)
    }()
    
    private lazy var clockImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.image = UIImage.systemAsset(.clock)
        imageview.tintColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        label.text = "最近搜尋"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: - support
    private var appendHistoryArray: [String] = [String]()
    private var historyArray: [String] = [String]()
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    private var isSearchBarActive = false
    // MARK: - Table View
    private var tableView: UITableView = {
        var tableView = UITableView()
        tableView.rowHeight = 85
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(SearchResultTableViewCell.self,
                           forCellReuseIdentifier:
                            SearchResultTableViewCell.identifier)
        tableView.allowsSelection = true
        tableView.isUserInteractionEnabled = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private var hiddenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var titleView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var buttonsView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - supports
    private var filterDataList: [Show] = [Show]()
    private var searchedDataSource: [Show] = [Show]()
    private var buttonArray = [UIButton]()
    private var fetchedResultController: NSFetchedResultsController<SearchHistory>!
    private let viewContext = StorageManager.shared.persistentContainer.viewContext
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupSearchBar()
        setupTableViewData()
        
    }
    
    // MARK: - Button Views
    
    private func resetButtons() {
        width = 0
        height = 0
        buttonArray.forEach {
            $0.removeFromSuperview()
        }
        loadSaveData()
        fetchButtonsData()
        setupButttons()
        appendHistoryArray.removeAll()
        historyArray.removeAll()
    }
    
    private func fetchButtonsData() {
        if let data = StorageManager.shared.fetchSearchHistorys() {
            data.forEach {
                if let name = $0.showName {
                    appendHistoryArray.append(name)
                }
            }
        }
        historyArray = appendHistoryArray.reversed()
    }
    
    private func setupButttons() {
        if  historyArray.count == 0 {
            return
        } else {
            
            for index in 0 ..< historyArray.count {
                
                let button = UIButton(type: .system)
                button.tag = 100 + index
                button.addTarget(self, action: #selector(handleClick(_:)), for: .touchUpInside)
                button.layer.cornerRadius = 4
                button.backgroundColor = UIColor.setColor(lightColor: .systemGray5, darkColor: .darkGray)
                button.setTitleColor( UIColor.setColor(lightColor: .darkGray, darkColor: .white), for: .normal)
                
                let length = historyArray[index].getLabWidth(font: UIFont.systemFont(ofSize: 20), height: 13).width
                button.setTitle(historyArray[index], for: .normal)
                button.frame = CGRect(x: 10 + width, y: height, width: length + 10, height: 30)
                
                if 10 + width + length + 15 > UIScreen.main.bounds.width - 16 {
                    width = 0
                    height = height + button.frame.size.height + 10
                    button.frame = CGRect(x: 10 + width, y: height, width: length + 10, height: 30)
                }
                
                width = button.frame.size.width + button.frame.origin.x
                buttonArray.append(button)
                buttonsView.addSubview(button)
                
            }
        }
    }
    
    @objc func handleClick(_ button: UIButton) {
        
        if let buttonLabel = button.titleLabel,
           let buttonText = buttonLabel.text {
            filterDataSource(for: buttonText)
            searchController.searchBar.text = buttonText
            tableView.isHidden = false
            tableView.reloadData()
        }
        
    }
}

// MARK: -
extension SearchViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearchBarActive = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,
           searchText.isEmpty != true {
            filterDataSource(for: searchText)
            tableView.reloadData()
        } else {
            return
        }
        tableView.isHidden = false
//        self.searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchController.searchBar.text,
           searchText.isEmpty != true {
            StorageManager.shared.createSearchHistoryObject(showName: searchText)
        }
        resetButtons()
        tableView.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
//        if let searchText = searchController.searchBar.text,
//           searchText.isEmpty != true {
//            StorageManager.shared.createSearchHistoryObject(showName: searchText)
//            filterDataSource(for: searchText)
//            tableView.reloadData()
//        } else {
//            return
//        }
//        tableView.isHidden = false
//        tableView.searchController.searchBar.resignFirstResponder()
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearchBarActive = false
    }
}

// MARK: - UI configuration
extension SearchViewController {
    private func setupUI() {
        
        tableView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        view.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        view.addSubview(hiddenView)
        view.addSubview(buttonsView)
        view.addSubview(titleView)
        titleView.addSubview(clockImageView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(cleanHistoryButton)
        view.addSubview(tableView)
        cleanHistoryButton.addTarget(self, action: #selector(cleanSearchHistory), for: .touchUpInside)
        hiddenView.isHidden = true
        tableView.isHidden = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture!)
        
        NSLayoutConstraint.activate([
            
            clockImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            clockImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            clockImageView.heightAnchor.constraint(equalToConstant: 25),
            clockImageView.widthAnchor.constraint(equalToConstant: 25),
            
            titleLabel.leadingAnchor.constraint(equalTo: clockImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cleanHistoryButton.leadingAnchor, constant: -32),
            titleLabel.centerYAnchor.constraint(equalTo: clockImageView.centerYAnchor),
            
            titleView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            titleView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            titleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor),
            
            cleanHistoryButton.heightAnchor.constraint(equalToConstant: 25),
            cleanHistoryButton.trailingAnchor.constraint(
                equalTo: titleView.trailingAnchor, constant: -16),
            cleanHistoryButton.widthAnchor.constraint(equalToConstant: 25),
            cleanHistoryButton.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 8),
            
            buttonsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            buttonsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            buttonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
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
    
    @objc func cleanSearchHistory() {
        removeAllSearchHistory()
        buttonArray.forEach {
            $0.removeFromSuperview()
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if searchController.searchBar.isFirstResponder {
            searchController.searchBar.resignFirstResponder()
        }
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableViewData() {
        tapGesture?.isEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        FirestoreManager.getAllShowsData(completion: { [weak self] showArrayData in
            guard let self = self else { return }
            self.searchedDataSource = showArrayData
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filterDataList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier,
                                                 for: indexPath) as? SearchResultTableViewCell
        
        guard let cell = cell else { return UITableViewCell() }
        
        tapGesture?.cancelsTouchesInView = false
        
        cell.showNameLabel.text = filterDataList[indexPath.row].showName
        cell.showImageView.loadImage(filterDataList[indexPath.row].image)
        cell.playlistId = filterDataList[indexPath.row].playlistId
        cell.id = filterDataList[indexPath.row].id
        cell.selectionStyle = .default
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("\(indexPath.row)")
        
        YouTubeParameter.shared.playlistId = filterDataList[indexPath.row].playlistId
        
        let playerViewController = PlayerViewController()
        playerViewController.modalPresentationStyle = .fullScreen
        playerViewController.playlistId = filterDataList[indexPath.row].playlistId
        playerViewController.id = filterDataList[indexPath.row].id
        
        self.present(playerViewController, animated: true)

    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension SearchViewController: NSFetchedResultsControllerDelegate {
    
    func loadSaveData() {
        
        if fetchedResultController == nil {
            
            let request = NSFetchRequest<SearchHistory>(entityName: "SearchHistory")
            let sort = NSSortDescriptor(key: "showName", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 30
            
            fetchedResultController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil)
            fetchedResultController.delegate = self
        }
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Fetch failed")
        }
        
    }
    
    func removeAllSearchHistory() {
        
        if let data = StorageManager.shared.fetchSearchHistorys(),
           data.count == 0 {
            print("目前沒有搜尋紀錄")
        } else {
            StorageManager.shared.deleteAllSearchHistory()
        }
        
    }
    
    // MARK: - filterDataSource
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
