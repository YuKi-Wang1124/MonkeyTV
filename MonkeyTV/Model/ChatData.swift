//
//  DanMuMessage.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/17.
//

import Foundation
import FirebaseFirestore

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

struct ChatroomData: Codable, Hashable {
    let chatroomChat: ChatroomChat
    let videoId: String
    let id: String
    static func == (lhs: ChatroomData, rhs: ChatroomData) -> Bool {
           return lhs.id == rhs.id
    }
}

struct ChatroomChat: Codable, Hashable {
    let chatId: String?
    let content: String?
    let contentType: Int?
    let createdTime: Date?
    let userId: String?
}
