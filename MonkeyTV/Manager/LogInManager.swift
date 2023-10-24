//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/22.
//

import Foundation
import UIKit

class LogInManager {
    
    static func checkIfLoginIsRequired() -> Bool {
        
        if let lastLoginDate = UserDefaults.standard.object(forKey: "lastLoginDate") as? Date {
            let currentDate = Date()
            let calendar = Calendar.current
            if let days = calendar.dateComponents(
                [.day], from: lastLoginDate, to: currentDate).day, days >= 30 {
                return true
            }
        }
        return false
    }
}
