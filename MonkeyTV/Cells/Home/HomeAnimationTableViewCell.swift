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
    
    // Create a pager view
    let pagerView = FSPagerView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
        
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
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
            pagerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            pagerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        pagerView.itemSize = CGSize(width: 320, height: 200)
    }
    
    private func startAutoScrollTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.moveToNextPage()
        }
    }
    
    private func moveToNextPage() {
        let nextPage = currentPage + 1
        if nextPage < 15 { // 这里的15是总页数，根据你的实际情况修改
            pagerView.scrollToItem(at: nextPage, animated: true)
            currentPage = nextPage
        } else {
            // 如果已经到最后一页，可以返回第一页
            pagerView.scrollToItem(at: 0, animated: true)
            currentPage = 0
        }
    }
}

extension HomeAnimationTableViewCell: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 15
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = UIImage(imageLiteralResourceName: "cat")
        cell.textLabel?.text = "\(index)"
        cell.contentView.backgroundColor = .clear
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        true
    }
    
    func pagerView(_ pagerView: FSPagerView, didHighlightItemAt index: Int) {
        
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        true
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        
    }
    
    func pagerView(_ pagerView: FSPagerView, didEndDisplaying cell: FSPagerViewCell, forItemAt index: Int) {
        
    }
    
    func pagerViewWillBeginDragging(_ pagerView: FSPagerView) {
        
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        
    }
}
