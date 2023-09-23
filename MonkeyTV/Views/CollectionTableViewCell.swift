//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/15.
//

import UIKit

class CollectionTableViewCell: UITableViewCell, UICollectionViewDelegateFlowLayout {
    static let identifier = "\(CollectionTableViewCell.self)"
    var showVideoPlayerDelegate: ShowVideoPlayerDelegate?
    lazy var titleLabel: UILabel = {
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
    var snapshot = NSDiffableDataSourceSnapshot<OneSection, Show>()
    var dataSource: UICollectionViewDiffableDataSource<OneSection, Show>!
    var catalogType = 0
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        configureCollectionViewDataSource()
        Task {
            await getSnapshotsData()
        }
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func getSnapshotsData() async {
//        if cacheDataDictionary[index] != nil {
//            return
//        }
//        for index in 0 ..< showCatalogArray.count {
//            var snapshot = NSDiffableDataSourceSnapshot<OneSection, Show>()
            snapshot.appendSections([OneSection.main])
            let showArray = await FirestoreManager.findShowCatalogData(isEqualTo: catalogType)
            snapshot.appendItems(showArray, toSection: OneSection.main)
        await dataSource.apply(snapshot)
//            snapshot.append(snapshot)
//        }
        //        await self.collectionViewDataSource.apply(snapshot)
//        cacheDataDictionary[index] = snapshot
        //        print(snapshot.itemIdentifiers)
    }
    private func setupUI() {
        contentView.addSubview(collectionView)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configureCollectionViewDataSource() {
        dataSource =
        UICollectionViewDiffableDataSource<OneSection, Show>(
            collectionView: collectionView,
            cellProvider: { (colloctionvVew, indexPath, itemIdentifier) -> UICollectionViewCell? in
                let cell = colloctionvVew.dequeueReusableCell(
                    withReuseIdentifier: VideoCollectionViewCell.identifier,
                    for: indexPath) as? VideoCollectionViewCell
                
                cell?.label.text = itemIdentifier.showName
                cell?.coverImageView.loadImage(itemIdentifier.image)
                
                print("collectionView: \(indexPath.row)")
                return cell
                })
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 230)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40.0
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showVideoPlayerDelegate?.showVideoPlayer()
    }
}

