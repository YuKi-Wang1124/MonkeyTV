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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private let dispatchSemaphore = DispatchSemaphore(value: 1)
    private var model = [MKShow]()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        DispatchQueue.main.async {
//            self.dispatchSemaphore.wait()
//            self.getVideoCover(request: HomeRequest.show)
//            self.dispatchSemaphore.wait()
            tableView.dataSource = self
//            self.dispatchSemaphore.signal()
            tableView.delegate = self
//            self.dispatchSemaphore.wait()
//        }
        view.backgroundColor = .white
//        getVideoCover(request: HomeRequest.channel, decodeType: ChannelResponse.self)
        setUI()
    }
//    func updateTableViewDataSource() {
//        dataSource =
//        UITableViewDiffableDataSource<Section, MKShow>(tableView: tableView) {
//            tableView, indexPath, itemIdentifier in
//            let cell =
//            tableView.dequeueReusableCell(
//                withIdentifier: CollectionTableViewCell.identifier,
//                for: indexPath) as? CollectionTableViewCell
//            guard let cell = cell else { return UITableViewCell() }
//            cell.model = self.model
//            cell.updateDataSource()
//            cell.selectionStyle = .none
//            return cell
//        }
//        tableView.dataSource = dataSource
//        snapshot = NSDiffableDataSourceSnapshot<Section, MKShow>()
//        snapshot.appendSections([.animation])
//        let show = MKShow(image: "123", title: "123")
//        snapshot.appendItems([show], toSection: .animation)
//    }
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
                        self.model.append(show)
                        print(show)
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

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
        tableView.dequeueReusableCell(
            withIdentifier: CollectionTableViewCell.identifier,
            for: indexPath) as? CollectionTableViewCell
        guard let cell = cell else { return UITableViewCell() }
        cell.model = self.model
        cell.updateDataSource()
        cell.selectionStyle = .none
        return cell
    }
}

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
