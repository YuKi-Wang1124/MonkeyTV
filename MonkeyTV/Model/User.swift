//
//  User.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/23.
//

import Foundation
import FirebaseFirestore


enum LogInMethod: String, CaseIterable {
    case google = "Google"
    case apple = "Apple"
}

struct UserData {
    var id: String
    var email: String
    var userName: String
    var userImage: String
    var userStatus: Int
    var appleId: String
    var googleToken: String
    var googleIsBind: Bool
    var appleIsBind: Bool
    
    init(
        id: String,
        email: String,
        userName: String,
        userImage: String,
        userStatus: Int,
        appleId: String,
        googleToken: String,
        googleIsBind: Bool,
        appleIsBind: Bool
    ) {
        self.id = id
        self.email = email
        self.userName = userName
        self.userImage = userImage
        self.userStatus = userStatus
        self.appleId = appleId
        self.googleToken = googleToken
        self.googleIsBind = googleIsBind
        self.appleIsBind = appleIsBind
    }
    
    func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "email": email,
            "userName": userName,
            "userImage": userImage,
            "userStatus": userStatus,
            "appleId": appleId,
            "googleToken": googleToken,
            "googleIsBind": googleIsBind,
            "appleIsBind": appleIsBind
        ]
    }
}

struct ChatroomChatData {
    
    var chatroomChat: [String: Any]
    var videoId: String
    var id: String

    init(
        text: String,
        userId: String,
        userName: String,
        userImage: String,
        videoId: String,
        id: String
    ) {
        chatroomChat = [
            "chatId": UUID().uuidString,
            "content": text,
            "contentType": 0,
            "createdTime": FirebaseFirestore.Timestamp(),
            "userId": userId,
            "userName": userName,
            "userImage": userImage
        ] as [String: Any]
        self.videoId = videoId
        self.id = id
    }

    func asDictionary() -> [String: Any] {
        return ["chatroomChat": chatroomChat, "videoId": videoId, "id": id]
    }
}
