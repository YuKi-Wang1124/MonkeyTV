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
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(
            VideoCollectionViewCell.self,
            forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        model.append(MKShow(image: "11", title: "111233333"))
        contentView.addSubview(collectionView)
        self.setupUI()
        updateDataSource()
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
            cellProvider: {
            (colloctionvVew, indexPath, item) -> UICollectionViewCell? in
            let cell = colloctionvVew.dequeueReusableCell(
                withReuseIdentifier: VideoCollectionViewCell.identifier,
                for: indexPath) as? VideoCollectionViewCell
            cell?.label.text = item.title
            return cell
        })
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

extension CollectionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if let viewWidth = UIScreen.current?.bounds.size.width {
//            return  CGSize(width: viewWidth / 2, height: viewWidth / 2 * 9 / 16)
//        }
        return CGSize(width: 300, height: 100)
    }
}

enum OneSection {
    case main
}
