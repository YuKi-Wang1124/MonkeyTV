//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/16.
//

import Foundation
import UIKit

class DanMu: Hashable {
    
    var row: Int = 0
    var label: UILabel = UILabel()
    var speed: CGFloat = 0
    var isMe: Bool = false
    
    init() {
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor(white: 1, alpha: 0.9)
        label.shadowColor = UIColor.black
        label.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    static func == (lhs: DanMu, rhs: DanMu) -> Bool {
        return true
    }
    
    func hash(into hasher: inout Hasher) {
    }
}

class BulletChatView: UIView {
    
    var displayLink: CADisplayLink?
    var lineHeight: CGFloat = 26
    var gap: CGFloat = 20
    var minSpeed: CGFloat = 0.05
    var maxSpeed: CGFloat = 0.5
    var isPause: Bool = false
    var danmus: [DanMu] = []
    var danmuQueue: [(String, Bool)] = []
    var removeDanmus = [DanMu]()
    var timer: Timer?
    var removeTime: Timer?
    
    lazy var myFrameHeight = self.bounds.size.height
    lazy var myFrameWidth = self.bounds.size.width
    
    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: RunLoop.current, forMode: .common)
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(handleDanMuQueue),
                                     userInfo: nil, repeats: true)
        
        removeTime = Timer.scheduledTimer(timeInterval: 3,
                                     target: self,
                                     selector: #selector(removeDanMuQueue),
                                     userInfo: nil, repeats: true)
    }
    
    deinit {
        displayLink?.remove(from: RunLoop.current, forMode: .common)
        timer = nil
        removeTime = nil
    }
    
    @objc func handleDanMuQueue() {
        if danmuQueue.isEmpty {
            return
        }
        let danmu = danmuQueue.removeFirst()
        addDanMu(text: danmu.0, isMycomment: danmu.1)
    }
    
    @objc func addDanMu(text: String, isMycomment: Bool) {
        
        let danmu = DanMu()
        danmu.label.frame.origin.x = self.bounds.size.width
        danmu.label.text = text
        danmu.label.sizeToFit()
        
        if isMycomment {
            danmu.label.textColor = .systemYellow
        }
        var linelasts: [DanMu?] = []
        let rows: Int = Int(self.bounds.size.height / lineHeight)
                
        for _ in 0..<rows {
            linelasts.append(nil)
        }
        
        for dumu in danmus {
            if dumu.row >= rows {
                return
            }
            if linelasts[dumu.row] != nil {
                let endx = danmu.label.frame.origin.x
                let targetx = linelasts[dumu.row]!.label.frame.origin.x
                if endx > targetx {
                    linelasts[dumu.row] = dumu
                }
            } else {
                linelasts[dumu.row] = dumu
            }
        }
        
        var isMatch = false
        
        for index in 0..<linelasts.count {
            if let dumu = linelasts[index] {
                let endx = dumu.label.frame.origin.x + dumu.label.frame.size.width + gap
                if endx < self.bounds.size.width {
                    danmu.row = index
                    var mySpeed = self.bounds.size.width / endx * dumu.speed
                    mySpeed = CGFloat.minimum(mySpeed, maxSpeed)
                    danmu.speed = CGFloat.random(in: minSpeed ... mySpeed)
                    isMatch = true
                }
            } else {
                danmu.row = index
                danmu.speed = CGFloat.random(in: minSpeed...maxSpeed)
                isMatch = true
            }
        }
        
        if isMatch == false {
            danmuQueue.append((text, isMycomment))
            return
        }
        
        danmu.label.frame.origin.y = lineHeight * CGFloat(danmu.row)
        self.addSubview(danmu.label)
        self.danmus.append(danmu)
    }
    
    @objc func update(_ displayLink: CADisplayLink) {
        
        if isPause == true {
            return
        }
        
        for danmu in danmus {
            if danmu.label.frame.origin.x >= -danmu.label.frame.size.width {
                danmu.label.frame.origin.x -= danmu.speed
            }
            if danmu.label.frame.origin.x < -danmu.label.frame.size.width && !removeDanmus.contains(danmu) {
                removeDanmus.append(danmu)
            }
        }
    }
        
    @objc func removeDanMuQueue() {
        if let danmu = removeDanmus.first {
            danmu.label.removeFromSuperview()
            removeDanmus.removeFirst()
        }
    }
    
    public func removeAllDanMuQueue() {
        for danmu in danmus {
            danmu.label.isHidden = true
            removeDanmus.append(danmu)
        }
        danmus.removeAll()
    }
}
