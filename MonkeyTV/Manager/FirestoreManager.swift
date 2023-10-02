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
    static let hotShow = FirestoreManager.shared.collection("HotShow")
    
    static func fetchHotShowData() async -> [Show] {
            var array = [Show]()
            do {
                let querySnapshot = try await self.hotShow.getDocuments()
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
    
    static func findShowCatalogData(
        isEqualTo value: Int
    ) async -> [Show] {
            var array = [Show]()
            do {
                let querySnapshot = try await self.show.whereField("type", isEqualTo: value).getDocuments()
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
    
    static func getAllShowsData(completion: @escaping ([Show]) -> Void ) {
        var showArray = [Show]()
        FirestoreManager.show.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Get data fail: \(error.localizedDescription)")
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                        let decodedObject = try JSONDecoder().decode(Show.self, from: jsonData)
                        showArray.append(decodedObject)
                        
                    } catch {
                        print("JSONSerialization & JSONDecoder : \(error)")
                    }
                }
                completion(showArray)
            }
        }
    }
}
