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
    static let bulletChat = FirestoreManageer.shared.collection("BulletChat")
    static let chatroom = FirestoreManageer.shared.collection("Chatroom")
    static let show = FirestoreManageer.shared.collection("Show")
}
