//
//  Fire.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/18.
//

import FirebaseCore
import FirebaseFirestore

class FirestoreManageer {
    static let shared = Firestore.firestore()
    static let bulletChatCollection = FirestoreManageer.shared.collection("BulletChat")
    static let chatroomCollection = FirestoreManageer.shared.collection("Chatroom")
}

    
