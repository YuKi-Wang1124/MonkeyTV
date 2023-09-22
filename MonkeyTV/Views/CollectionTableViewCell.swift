//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/15.
//

import UIKit

class CollectionTableViewCell: UITableViewCell, UICollectionViewDelegateFlowLayout {
    static let identifier = "\(CollectionTableViewCell.self)"
    var delegate: ShowVideoPlayerDelegate?
    var model = [MKShow]()
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.text = "多一點健康"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        var collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(
            VideoCollectionViewCell.self,
            forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        getVideoCover(request: HomeRequest.show)
//        updateDataSource()
        collectionView.delegate = self
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(collectionView)
        contentView.addSubview(titleLabel)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        collectionView.backgroundColor = UIColor.white
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
   
//    func getVideoCover(request: Request) {
//        let decoder = JSONDecoder()
//        HTTPClient.shared.request(request, completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let data):
//                do {
//                    let info = try decoder.decode(PlaylistListResponse.self, from: data)
//                    info.items.forEach({
//                        let show = MKShow(image: $0.snippet.thumbnails.medium.url,
//                                          title: $0.snippet.title,
//                                          playlistId: $0.id)
//                        DispatchQueue.main.async {
//                            self.snapshot.appendItems([show], toSection: .main)
//                            self.dataSource.apply(self.snapshot)
//                            self.collectionView.reloadData()
//                        }
//                    })
//                } catch {
//                    print(Result<Any>.failure(error))
//                }
//            case .failure(let error):
//                print(Result<Any>.failure(error))
//            }
//        })
//    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 230)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50.0
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.showVideoPlayer()
    }
}

