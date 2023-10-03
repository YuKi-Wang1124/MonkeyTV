//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/15.
//

import UIKit
import FSPagerView

class HomeAnimationTableViewCell: UITableViewCell {
    
    static let identifier = "\(HomeAnimationTableViewCell.self)"
    private var timer: Timer?
    private var currentPage = 0
    private var hotShowArray = [Show]()

    var totalCount = 14
    let pagerView = FSPagerView()
    var showVideoPlayerDelegate: ShowVideoPlayerDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.dataSource = self
        pagerView.delegate = self
        Task {
            await getHotShow()
            setupCellUI()

        }
    }
    
    override func prepareForReuse() {
        stopAutoScrollTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopAutoScrollTimer()
    }
    
    private func stopAutoScrollTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupCellUI() {
        
        startAutoScrollTimer()
        
        contentView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        contentView.addSubview(pagerView)
        
        pagerView.translatesAutoresizingMaskIntoConstraints = false
        pagerView.transformer = FSPagerViewTransformer(type: .overlap)
        
        NSLayoutConstraint.activate([
            pagerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            pagerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            pagerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            pagerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
        
        pagerView.itemSize = CGSize(width: 320, height: 200)
    }
    
    private func startAutoScrollTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.moveToNextPage()
        }
    }
    
    private func moveToNextPage() {
        let nextPage = currentPage + 1
        if nextPage < hotShowArray.count {
            pagerView.scrollToItem(at: nextPage, animated: true)
            currentPage = nextPage
        } else {
            pagerView.scrollToItem(at: 0, animated: false)
            currentPage = 0
        }
    }
}

// MARK: -
extension HomeAnimationTableViewCell: FSPagerViewDelegate, FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return hotShowArray.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.loadImage(hotShowArray[index].image)
        cell.contentView.backgroundColor = .clear
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        YouTubeParameter.shared.playlistId = hotShowArray[index].playlistId
        showVideoPlayerDelegate?.showVideoPlayer(showName: hotShowArray[index].showName,
                                                 playlistId: hotShowArray[index].playlistId,
                                                 id: hotShowArray[index].playlistId,
                                                 showImage: hotShowArray[index].image)
    }
    
    // MARK: - Get Hot Channel
    private func getHotShow() async {
        hotShowArray = await FirestoreManager.fetchHotShowData()
    }
    
    private func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScrollTimer()
    }
    
    private func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startAutoScrollTimer()
    }
}
