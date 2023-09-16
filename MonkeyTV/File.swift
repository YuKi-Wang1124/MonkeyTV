//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/16.
//

import Foundation
import UIKit

class DanMu {
    var row: Int = 0
    var label: UILabel = UILabel()
    var speed: CGFloat = 0
    var isMe: Bool = false
    init() {
        label.textColor = .white
    }
}

class DanMuView: UIView {
    var displayLink: CADisplayLink?
    var lineHeight: CGFloat = 26
    var gap: CGFloat = 20
    var minSpeed: CGFloat = 1
    var maxSpeed: CGFloat = 2
    var danmus: [DanMu] = []
    var danmuQueue: [(String, Bool)] = []
    var timer: Timer?
    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: RunLoop.current, forMode: .common)
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(handleDanMuQueue),
                                     userInfo: nil, repeats: true)
    }
    @objc func handleDanMuQueue() {
        if danmuQueue.isEmpty {
            return
        }
        let danmu = danmuQueue.removeFirst()
        addDanMu(text: danmu.0, isMe: danmu.1)
    }
    @objc func addDanMu(text: String, isMe: Bool) {
        let danmu = DanMu()
        danmu.label.frame.origin.x = self.frame.size.width
        danmu.label.text = text
        danmu.label.sizeToFit()
        if isMe {
            danmu.label.textColor = .systemYellow
        }
        var linelasts: [DanMu?] = []
        let rows: Int = Int(self.frame.size.height / lineHeight)
        for _ in 0..<rows {
            linelasts.append(nil)
        }
        for dumu in danmus {
            if dumu.row >= linelasts.count {
                break
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
                if endx < self.frame.size.width {
                    danmu.row = index
                    var ms = self.frame.size.width / endx * dumu.speed
                    ms = CGFloat.minimum(ms, maxSpeed)
                    danmu.speed = CGFloat.random(in: minSpeed...ms)
                    isMatch = true
                    break
                }
            } else {
                danmu.row = index
                danmu.speed = CGFloat.random(in: minSpeed...maxSpeed)
                isMatch = true
                break
            }
        }
        if isMatch == false {
            danmuQueue.append((text, isMe))
            return
        }
        danmu.label.frame.origin.y = lineHeight * CGFloat(danmu.row)
        self.addSubview(danmu.label)
        self.danmus.append(danmu)
    }
    @objc func update(_ displayLink: CADisplayLink) {
        for index in 0..<danmus.count {
            let danmu = danmus[index]
            danmu.label.frame.origin.x -= danmu.speed
            if danmu.label.frame.origin.x < -danmu.label.frame.size.width {
                danmu.label.removeFromSuperview()
                danmus.remove(at: index)
                break
            }
        }
    }
}
