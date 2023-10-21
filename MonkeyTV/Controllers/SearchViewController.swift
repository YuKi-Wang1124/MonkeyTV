//
//  ViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import CoreData
import Lottie

class SearchViewController: UIViewController, CleanSearchHistoryDelegate {
        
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "請輸入片名"
        return searchController
    }()
    
    private lazy var cleanHistoryButton: UIButton = {
        return CustomButton(
            image: UIImage.systemAsset(.trash, configuration: UIImage.symbolConfig),
            color: UIColor.setColor(lightColor: .darkGray, darkColor: .white),
            cornerRadius: 30,
            backgroundColor: UIColor.clear)
    }()
    
    private lazy var clockImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.image = UIImage.systemAsset(.clock)
        imageview.tintColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = CustomLabel(
            fontSize: 17,
            textColor: UIColor.darkAndWhite,
            numberOfLines: 0,
            textAlignment: .left)
        label.text = "最近搜尋"
        return label
    }()
    
    private lazy var noDataLabel: UILabel = {
        let label = CustomLabel(
            fontSize: 17,
            textColor: UIColor.darkAndWhite,
            numberOfLines: 0,
            textAlignment: .left)
        label.text = "沒有搜尋資料"
        return label
    }()
    
    // MARK: - support
    private var appendHistoryArray: [String] = [String]()
    private var historyArray: [String] = [String]()
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    private var isSearchBarActive: Bool = false
    
    private lazy var tableView: UITableView = {
        return  CustomTableView(rowHeight: UITableView.automaticDimension,
                                separatorStyle: .none,
                                allowsSelection: true,
                                registerCells: [ShowTableViewCell.self])
    }()
    
    private lazy var hiddenView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var animationView: LottieAnimationView?
    private var tapGesture: UITapGestureRecognizer?
    
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
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchController.searchBar.text,
           searchText.isEmpty != true {
            StorageManager.shared.createSearchHistoryObject(showName: searchText)
        }
        resetButtons()
        tableView.isHidden = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearchBarActive = false
    }
}

// MARK: - UI configuration

extension SearchViewController {
    private func setupUI() {
        tableView.backgroundColor = .baseBackgroundColor
        tableView.isUserInteractionEnabled = true
        tableView.isHidden = true
        
        view.backgroundColor = .baseBackgroundColor
        view.addSubview(buttonsView)
        view.addSubview(hiddenView)
        view.addSubview(titleView)
        titleView.addSubview(clockImageView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(cleanHistoryButton)
        view.addSubview(tableView)
        
        cleanHistoryButton.addTarget(self, action: #selector(cleanSearchHistory), for: .touchUpInside)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture!)
        
        animationView = .init(name: "notFound")
        guard let animationView = animationView else { return }
        animationView.loopMode = .loop
        tableView.addSubview(animationView)
        animationView.addSubview(noDataLabel)
        animationView.play()
        animationView.isHidden = true
        
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
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            noDataLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            noDataLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            noDataLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            noDataLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        animationView.frame = view.bounds
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ShowTableViewCell.identifier,
                                                 for: indexPath) as? ShowTableViewCell
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
                
        YouTubeParameter.shared.playlistId = filterDataList[indexPath.row].playlistId
        
        let playerViewController = PlayerViewController()
        playerViewController.modalPresentationStyle = .fullScreen
        playerViewController.playlistId = filterDataList[indexPath.row].playlistId
        playerViewController.id = filterDataList[indexPath.row].id
        playerViewController.showImage = filterDataList[indexPath.row].image
        
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
            print("Fetch SearchHistory failed")
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
                guard let animationView = animationView else { return true }
                animationView.isHidden = true
                filterDataList.append(show)
                return true
            } else {
                return false
            }
        })
        
        if self.filterDataList.isEmpty == true {
            guard let animationView = animationView else { return }
            animationView.isHidden = false
        }
    }
}
