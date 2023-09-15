//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/15.
//

import Foundation

import UIKit

class HorizontalScrollTableViewCell: UITableViewCell {
    static let identifier = "HorizontalScrollTableViewCell"
    private lazy var collectionView = {
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(
            VideoCollectionViewCell.self,
            forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
        contentView.backgroundColor = .white
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(collectionView)
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
}
