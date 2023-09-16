//
//  HomeViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
class HomeViewController: UIViewController {
    private lazy var tableView = {
        var tableView = UITableView()
        tableView.rowHeight = 300
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(CollectionTableViewCell.self,
                           forCellReuseIdentifier:
                            CollectionTableViewCell.identifier)
        tableView.register(VideoTableViewCell.self,
                           forCellReuseIdentifier:
                            VideoTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private var snapshot = NSDiffableDataSourceSnapshot<Section, MKShow>()
    private var dataSource: UITableViewDiffableDataSource<Section, MKShow>!
    private let dispatchSemaphore = DispatchSemaphore(value: 1)
    private var model = [MKShow]()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        DispatchQueue.main.async {
//            self.dispatchSemaphore.wait()
//            self.dispatchSemaphore.signal()
//            self.dispatchSemaphore.wait()
            self.updateTableViewDataSource()
//            self.dispatchSemaphore.signal()
//            tableView.dataSource = self
//            tableView.delegate = self
//            self.dispatchSemaphore.wait()
//        }
        view.backgroundColor = .white
//        getVideoCover(request: HomeRequest.channel, decodeType: ChannelResponse.self)
        setUI()
        self.getVideoCover(request: HomeRequest.show)
    }
    func updateTableViewDataSource() {
        dataSource =
        UITableViewDiffableDataSource<Section, MKShow>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            if indexPath.row == 0 {
                let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: CollectionTableViewCell.identifier,
                    for: indexPath) as? CollectionTableViewCell
                guard let cell = cell else { return UITableViewCell() }
                return cell
            }
//            let cell =
//            tableView.dequeueReusableCell(
//                withIdentifier: VideoTableViewCell.identifier,
//                for: indexPath) as? VideoTableViewCell
//            guard let cell = cell else { return UITableViewCell() }
//            cell.showNameLabel.text = itemIdentifier.title
//            cell.selectionStyle = .none
//            return cell
            return UITableViewCell()
        }
        tableView.dataSource = dataSource
        snapshot = NSDiffableDataSourceSnapshot<Section, MKShow>()
        snapshot.appendSections([.animation])
//        let show = MKShow(image: "13", title: "123")
//        snapshot.appendItems([show], toSection: .animation)
    }
    // MARK: - call api to get images and titles
    func getVideoCover(request: Request) {
        let decoder = JSONDecoder()
        HTTPClient.shared.request(request, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let info = try decoder.decode(PlaylistListResponse.self, from: data)
                    info.items.forEach({
                        let show = MKShow(image: $0.snippet.thumbnails.medium.url,
                                          title: $0.snippet.title)
//                        self.model.append(show)
//                        print(show)
                        self.snapshot.appendItems([show], toSection: .animation)
                        self.dataSource.apply(self.snapshot)
                    })
                } catch {
                    print(Result<Any>.failure(error))
                }
            case .failure(let error):
                print(Result<Any>.failure(error))
            }
        })
    }
    // MARK: - UI configuration
    func setUI() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

//extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        3
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell =
//        tableView.dequeueReusableCell(
//            withIdentifier: CollectionTableViewCell.identifier,
//            for: indexPath) as? CollectionTableViewCell
//        guard let cell = cell else { return UITableViewCell() }
//        cell.model = self.model
//        cell.updateDataSource()
//        cell.selectionStyle = .none
//        return cell
//    }
//}

enum Section {
    case animation
}

struct MKShow: Hashable {
    var image: String
    var title: String
}

struct SuccessParser<T: Codable>: Codable {
    let data: T
    let paging: Int?
    enum CodingKeys: String, CodingKey {
        case data
        case paging = "next_paging"
    }
}

struct FailureParser: Codable {
    let errorMessage: String
}

struct Model: Hashable {
    var text: String
    var image: String
}
