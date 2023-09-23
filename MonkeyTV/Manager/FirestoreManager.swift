//
//  Fire.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/18.
//

import FirebaseCore
import FirebaseFirestore

class FirestoreManager {
    static let shared = Firestore.firestore()
    static let bulletChat = FirestoreManager.shared.collection("BulletChat")
    static let chatroom = FirestoreManager.shared.collection("Chatroom")
    static let show = FirestoreManager.shared.collection("Show")
    static func findShowCatalogData(
        isEqualTo value: Int) async -> [Show] {
            var array = [Show]()
            do {
                let querySnapshot = try await self.show.whereField( "type", isEqualTo: value).getDocuments()
                for document in querySnapshot.documents {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    let decodedObject = try JSONDecoder().decode(Show.self, from: jsonData)
                    array.append(decodedObject)
                }
            } catch {
                print("\(error)")
            }
            return array
        }
}
