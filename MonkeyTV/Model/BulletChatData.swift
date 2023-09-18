//
//  DanMuMessage.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/17.
//

import Foundation

struct BulletChatData: Codable {
    let id: String
    let bulletChat: BulletChat
    let videoId: String
    enum CodingKeys: String, CodingKey {
        case videoId
        case id
        case bulletChat = "bulletChat"
    }
}
struct BulletChat: Codable, Comparable {
    let content: String
    let contentType: Int
    let chatId: String
    let popTime: Float
    let userId: String
    static func < (lhs: BulletChat, rhs: BulletChat) -> Bool {
           return lhs.popTime < rhs.popTime
       }

       static func == (lhs: BulletChat, rhs: BulletChat) -> Bool {
           return lhs.popTime == rhs.popTime
       }
}
