//
//  HomeViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import FirebaseFirestore

class HomeViewController: BaseViewController {
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
//        VideoLauncher.shared
        tableView.backgroundColor = UIColor.white
        self.updateTableViewDataSource()
        //        getVideoCover(request: HomeRequest.channel, decodeType: ChannelResponse.self)
        setUI()
        self.getVideoCover(request: HomeRequest.show)
        view.backgroundColor = UIColor.white
    }
    // MARK: - Update TableView DataSource
    func updateTableViewDataSource() {
        dataSource =
        UITableViewDiffableDataSource<Section, MKShow>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            if indexPath.row == 0 {
                let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: CollectionTableViewCell.identifier,
                    for: indexPath) as? CollectionTableViewCell
                guard let cell = cell else { return UITableViewCell() }
                cell.delegate = self
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
                                          title: $0.snippet.title, playlistId: $0.id)
                        self.model.append(show)
                        //                        print($0.id)
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
}

extension HomeViewController: ShowVideoPlayerDelegate {
    func showVideoPlayer() {
        VideoLauncher.shared.videoId = "FjJtmJteK58"
        VideoLauncher.shared.showVideoPlayer()
    }
}

extension HomeViewController {
    // MARK: - UI configuration
    private func setUI() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
