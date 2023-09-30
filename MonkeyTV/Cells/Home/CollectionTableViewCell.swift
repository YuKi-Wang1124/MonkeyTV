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
        return UILabel.createTitleLabel(text: "")
    }()
    var showVideoPlayerDelegate: ShowVideoPlayerDelegate?
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
    var nextPageTableViewSnapshot = NSDiffableDataSourceSnapshot<OneSection, Playlist>()
    var dataSource: UICollectionViewDiffableDataSource<OneSection, Show>!
    var catalogType = 0
    // MARK: - init
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
    override func prepareForReuse() {
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
                
                guard let cell = cell else { return UICollectionViewCell() }
                
                cell.label.text = itemIdentifier.showName
                cell.coverImageView.loadImage(itemIdentifier.image)
                cell.playlistId = itemIdentifier.playlistId
                cell.id = itemIdentifier.id
                
                return cell
            })
    }
}
// MARK: -
extension CollectionTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.size.width
        return CGSize(width: (screenWidth - 40) / 2,
                      height: collectionView.frame.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24.0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        nextPageTableViewSnapshot.deleteAllItems()
        nextPageTableViewSnapshot.deleteSections([OneSection.main])
        
        if let cell = collectionView.cellForItem(at: indexPath) as? HomePageCollectionViewCell {
            
            YouTubeParameter.shared.playlistId = cell.playlistId
            showVideoPlayerDelegate?.showVideoPlayer(
                showName: cell.label.text!,
                playlistId: cell.playlistId,
                id: cell.id,
                showImage: cell.coverImageView.image ?? UIImage(imageLiteralResourceName: "cat"))
            
        } else { }
        
    }
}
// MARK: - setupCellUI
extension CollectionTableViewCell {
    private func setupCellUI() {
        collectionView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        contentView.backgroundColor =  UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        contentView.addSubview(collectionView)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
