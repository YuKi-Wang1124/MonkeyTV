//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/13.
//

import Foundation

class TimeFormatter {
    
    static let shared = TimeFormatter()
    
    private let dateFormatter = DateFormatter()

    private init() {
        dateFormatter.dateFormat = "HH:mm:ss"
    }

    func formatSecondsToHHMMSS(seconds: Float) -> String {
        let roundedSeconds = Int(seconds.rounded())
        let hours = roundedSeconds / 3600
        let minutes = (roundedSeconds % 3600) / 60
        let remainingSeconds = roundedSeconds % 60
        
        if hours > 0 {
            return formatTimeWithHours(hours, minutes, remainingSeconds)
        } else {
            return formatTimeWithoutHours(minutes, remainingSeconds)
        }
    }
    
    private func formatTimeWithHours(_ hours: Int, _ minutes: Int, _ seconds: Int) -> String {
        if let formattedTime = dateFormatter.date(from: "\(hours):\(minutes):\(seconds)") {
            return dateFormatter.string(from: formattedTime)
        } else {
            return "00:00:00"
        }
    }
    
    private func formatTimeWithoutHours(_ minutes: Int, _ seconds: Int) -> String {
        dateFormatter.dateFormat = "mm:ss"
        if let formattedTime = dateFormatter.date(from: "\(minutes):\(seconds)") {
            dateFormatter.dateFormat = "mm:ss"
            return dateFormatter.string(from: formattedTime)
        } else {
            return "00:00"
        }
    }
}
