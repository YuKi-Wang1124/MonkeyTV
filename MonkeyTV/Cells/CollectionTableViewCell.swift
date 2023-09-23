//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/15.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {
    static let identifier = "\(CollectionTableViewCell.self)"
    lazy var titleLabel: UILabel = {
        return UILabel.createTitleLabel(text: "多一點健康")
    }()
    private lazy var collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        var collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(
            HomePageCollectionViewCell.self,
            forCellWithReuseIdentifier: HomePageCollectionViewCell.identifier)
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
        setupCellUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Configure CollectionView
    private func getSnapshotsData() async {
        snapshot.appendSections([OneSection.main])
        let showArray = await FirestoreManager.findShowCatalogData(isEqualTo: catalogType)
        snapshot.appendItems(showArray, toSection: OneSection.main)
        await dataSource.apply(snapshot)
    }
    func configureCollectionViewDataSource() {
        dataSource =
        UICollectionViewDiffableDataSource<OneSection, Show>(
            collectionView: collectionView,
            cellProvider: { (colloctionvVew, indexPath, itemIdentifier) -> UICollectionViewCell? in
                let cell = colloctionvVew.dequeueReusableCell(
                    withReuseIdentifier: HomePageCollectionViewCell.identifier,
                    for: indexPath) as? HomePageCollectionViewCell
                cell?.label.text = itemIdentifier.showName
                cell?.coverImageView.loadImage(itemIdentifier.image)
                return cell
            })
    }
}
// MARK: -
extension CollectionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180,
                      height: collectionView.frame.height)
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
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        VideoLauncher.shared.videoId = "FjJtmJteK58"
        VideoLauncher.shared.showVideoPlayer()
    }
}
// MARK: - setupCellUI
extension CollectionTableViewCell {
    private func setupCellUI() {
        contentView.addSubview(collectionView)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
