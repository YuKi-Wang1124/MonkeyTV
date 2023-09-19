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
}

struct ChatroomChat: Codable, Hashable {
    let chatId: String
    let content: String
    let contentType: Int
    let createdTime: Date
    let userId: String
}


extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options) {
        self.init()
        self.formatOptions = formatOptions
    }
}

extension Formatter {
    static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}

extension Date {
    var iso8601withFractionalSeconds: String { return Formatter.iso8601withFractionalSeconds.string(from: self) }
}

extension String {
    var iso8601withFractionalSeconds: Date? { return Formatter.iso8601withFractionalSeconds.date(from: self) }
}
