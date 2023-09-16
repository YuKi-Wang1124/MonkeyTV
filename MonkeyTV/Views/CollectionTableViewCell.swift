//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/15.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {
    static let identifier = "CollectionTableViewCell"
    var model = [MKShow]()
    private var snapshot = NSDiffableDataSourceSnapshot<OneSection, MKShow>()
    private var dataSource: UICollectionViewDiffableDataSource<OneSection, MKShow>!
    private lazy var collectionView = {
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
        model.append(MKShow(image: "11",
                            title: "111233333"))
        getVideoCover(request: HomeRequest.show)
        updateDataSource()
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        contentView.addSubview(collectionView)
        setupUI()
    }
    override func prepareForReuse() {
        collectionView.dataSource = nil
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    func updateDataSource() {
        snapshot = NSDiffableDataSourceSnapshot<OneSection, MKShow>()
        snapshot.appendSections([.main])
        snapshot.appendItems(model, toSection: .main)
        dataSource =
        UICollectionViewDiffableDataSource<OneSection, MKShow>(
            collectionView: collectionView,
            cellProvider: { (colloctionvVew, indexPath, itemIdentifier) -> UICollectionViewCell? in
                let cell = colloctionvVew.dequeueReusableCell(
                    withReuseIdentifier: VideoCollectionViewCell.identifier,
                    for: indexPath) as? VideoCollectionViewCell
                cell?.label.text = itemIdentifier.title
                UIImage.displayThumbnailImage(from: itemIdentifier.image, completion: { image in
                    cell?.coverBtn.setImage(image, for: .normal)
                })
                return cell
            })
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
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
                        DispatchQueue.main.async {
                            self.snapshot.appendItems([show], toSection: .main)
                            self.dataSource.apply(self.snapshot)
                            self.collectionView.reloadData()
                        }
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

extension CollectionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 返回每个项目的大小
        return CGSize(width: 200,
                      height: collectionView.frame.height) // 這裡設定寬度，高度使用collectionView的高度
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoLauncher = VideoLauncher()
        videoLauncher.showVideoPlayer()
    }
}

enum OneSection {
    case main
}
