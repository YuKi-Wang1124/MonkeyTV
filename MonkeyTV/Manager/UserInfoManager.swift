//
//  LoginManager.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/6.
//

import Foundation

class UserInfoManager {
    
    static let email = KeychainItem.currentEmail
    
    static func userInfo() async -> UserInfo? {
        await FirestoreManager.fetchUserInfo(email: KeychainItem.currentEmail)
    }
    
    static func userIsLogIn() async -> Bool {
        if email.isEmpty == true {
            return false
        } else {
            return true
        }
    }
}
