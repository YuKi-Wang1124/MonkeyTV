//
//  HomeViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
class HomeViewController: UIViewController {
    lazy var tableView = {
        var tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    var dataSource: UITableViewDiffableDataSource<Section, String>!
    var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.delegate = self
//        getVideoCover(request: HomeRequest.channel, decodeType: ChannelInfo.self)
//        getVideoCover(request: HomeRequest.show, decodeType: PlaylistListResponse.self)
        setUI()
    }
    // MARK: - call api to get images and titles
    func getVideoCover<T>(request: Request, decodeType: T.Type) where T: Decodable {
        let decoder = JSONDecoder()
        HTTPClient.shared.request(request, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let info = try decoder.decode(decodeType, from: data)
                    print(info)
                    DispatchQueue.main.async {
                    }
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
        tableView.backgroundColor = .systemYellow
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension HomeViewController: UITableViewDelegate {
}

enum Section {
    case main
}

struct STSuccessParser<T: Codable>: Codable {
    let data: T
    let paging: Int?
    enum CodingKeys: String, CodingKey {
        case data
        case paging = "next_paging"
    }
}

struct STFailureParser: Codable {
    let errorMessage: String
}

