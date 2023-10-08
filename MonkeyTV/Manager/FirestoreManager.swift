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
    static let user = FirestoreManager.shared.collection("User")
    static let bulletChat = FirestoreManager.shared.collection("BulletChat")
    static let chatroom = FirestoreManager.shared.collection("Chatroom")
    static let show = FirestoreManager.shared.collection("Show")
    static let hotShow = FirestoreManager.shared.collection("HotShow")
    static let userBlockList = FirestoreManager.shared.collection("UserBlockList")
    static let userReportList = FirestoreManager.shared.collection("UserReportList")

    
    static func userBlock(userId: String, blockUserId: String) {
        
        let userIdDocumentRef = self.userBlockList.document(userId)
        let blockUserIdDocumentRef = self.userBlockList.document(blockUserId)

        userIdDocumentRef.updateData([
            "blocklist": FieldValue.arrayUnion([blockUserId])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Value added to the array.")
            }
        }
        
        blockUserIdDocumentRef.updateData([
            "blocklist": FieldValue.arrayUnion([userId])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Value added to the array.")
            }
        }
    }
    
    static func signInUserInfo(email: String, data: [String: Any]) {
        FirestoreManager.user.document(email).setData(data) { error in
            if error != nil {
                print("Error adding document: \(String(describing: error))")
            } else { }
        }
        
        let blankBlocklist: [String: Any] = ["blocklist": [""]]
        
        FirestoreManager.userBlockList.document(email).setData(blankBlocklist) { error in
            if error != nil {
                print("Error adding document: \(String(describing: error))")
            } else { }
        }
    }
    
    static func fetchUserInfo(
        email: String
    ) async -> UserInfo? {
        do {
            let document = try await self.user.document(email).getDocument()
            
            let jsonData = try JSONSerialization.data(withJSONObject: document.data()!)
            let decodedObject = try JSONDecoder().decode(UserInfo.self, from: jsonData)
            return decodedObject
        } catch {
            print("\(error)")
        }
        return nil
    }
    
    static func updateUserInfo(email: String, data: [String: Any]) {
        
        FirestoreManager.user.document(email).updateData(data) { error in
            if error != nil {
                print("Error adding document: \(String(describing: error))") } else { }
        }
    }
    
    static func userIsExist(email: String) async -> Bool {
        
        let documentRef = self.user.document(email)
        
        do {
            let documentSnapshot = try await documentRef.getDocument()
            if documentSnapshot.exists {
                print("Document exists")
                return true
            } else {
                print("Document does not exist")
                return false
            }
        } catch {
            print("Error fetching document: \(error)")
            return false
        }
    }
    
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
