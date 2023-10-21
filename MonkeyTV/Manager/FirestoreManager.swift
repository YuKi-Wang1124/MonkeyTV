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
    static let myFavoriteShow = FirestoreManager.shared.collection("MyFavoriteShow")
    static let useDefaultData = FirestoreManager.shared.collection("UseDefaultData")
    static let defaultShow = FirestoreManager.shared.collection("DefaultShow")
    
    // MARK: - Block & Report
    
    static func userBlock(
        userId: String,
        blockUserId: String) {
            
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
    
    static func report(
        userId: String,
        reportId: String,
        reason: String,
        message: String) {
            
            let id = FirestoreManager.userReportList.document().documentID
            let data: [String: Any] = [ "id": id, "userId": userId, "reportId": reportId,
                                        "reason": reason, "message": message]
            FirestoreManager.userReportList.document(id).setData(data) { error in
                if error != nil {
                    print("Error adding document: \(String(describing: error))")
                } else { }
            }
        }
    
    // MARK: - my favorite
    
    static func fetchMyFavoriteShow(
        email: String
    ) async -> [ShowData]? {
        
        if email == "" {
            return nil
        }
        
        do {
            let document = try await self.myFavoriteShow.document(email).getDocument()
            let jsonData = try JSONSerialization.data(withJSONObject: document.data()!)
            let decodedObject = try JSONDecoder().decode(MyFavoriteShowData.self, from: jsonData)
            return decodedObject.myFavoriteShow
        } catch {
            print("\(error)")
        }
        return nil
    }
    
    static func addToMyFavorite(
        email: String,
        playlistId: String,
        showImage: String,
        showName: String) {
            
            let myFavoriteShowDocumentRef = self.myFavoriteShow.document(email)
            let id = FirestoreManager.myFavoriteShow.document().documentID
            let myShowData: [String: Any] = ["id": id, "playlistId": playlistId,
                                             "showImage": showImage, "showName": showName]
            myFavoriteShowDocumentRef.updateData([
                "myFavoriteShow": FieldValue.arrayUnion([myShowData])
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Value added to the array.")
                }
            }
        }
    
    static func deleteToMyFavorite(
        email: String,
        playlistId: String
    ) async {
        
        if var showArray = await FirestoreManager.fetchMyFavoriteShow(email: email) {
            showArray = showArray.filter { showData in
                return showData.playlistId != playlistId
            }
            
            var firestoreDataArray = [[String: Any]]()
            
            for showData in showArray {
                let firestoreData: [String: Any] = [
                    "playlistId": showData.playlistId,
                    "showImage": showData.showImage,
                    "id": showData.id,
                    "showName": showData.showName
                ]
                firestoreDataArray.append(firestoreData)
            }
            
            let myFavoriteShow = ["myFavoriteShow": firestoreDataArray]
            self.myFavoriteShow.document(email).updateData(myFavoriteShow) { error in
                if error != nil {
                    print("Error adding document: \(String(describing: error))") } else { }
            }
            
        }
    }
    
    static func deleteAllMyFavorite(
        email: String
    ) async {
        
        var firestoreDataArray = [[String: Any]]()
        let id = FirestoreManager.myFavoriteShow.document().documentID
        let firestoreData: [String: Any] = [
            "playlistId": "",
            "showImage": "",
            "id": id,
            "showName": ""]
        firestoreDataArray.append(firestoreData)
        let myFavoriteShow = ["myFavoriteShow": firestoreDataArray]
        
        DispatchQueue.main.async {
            self.myFavoriteShow.document(email).updateData(myFavoriteShow) { error in
                if error != nil {
                    print("Error adding document: \(String(describing: error))") } else { }
            }
        }
    }
    
    static func checkPlaylistIdInMyFavorite(
        email: String,
        playlistIdToCheck: String,
        completion: @escaping (Bool?, Error?) -> Void
    ) async {
        if email == "" {
            completion(false, nil)
        }
        
        if let showarray = await FirestoreManager.fetchMyFavoriteShow(email: email) {
            
            let containsPlaylistId = showarray.contains { showData in
                return showData.playlistId == playlistIdToCheck
            }
            
            if containsPlaylistId {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    // MARK: - User
    
    static func signInUserInfo(email: String,
                               data: [String: Any]) {
        
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
        
        let id = FirestoreManager.myFavoriteShow.document().documentID
        let myShowData: [String: Any] = ["myFavoriteShow":
                                            [["id": id, "playlistId": "",
                                              "showImage": "", "showName": ""]]]
        FirestoreManager.myFavoriteShow.document(email).setData(myShowData) { error in
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
    
    // MARK: - Show
    
    static func fetchHotShowData() async -> [Show] {
        
        var array = [Show]()
        var isDefault: Bool?
        
        do {
            let querySnapshot = try await self.useDefaultData.getDocuments()
            for document in querySnapshot.documents {
                let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                let decodedObject = try JSONDecoder().decode(UseDefaultData.self, from: jsonData)
                isDefault = decodedObject.isDefault
            }
        } catch {
            print("\(error)")
        }
        
        if isDefault == true {
            do {
                let querySnapshot = try await self.defaultShow.getDocuments()
                for document in querySnapshot.documents {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    let decodedObject = try JSONDecoder().decode(Show.self, from: jsonData)
                    array.append(decodedObject)
                }
            } catch {
                print("\(error)")
            }
        } else {
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
        }
        return array
    }
    
    static func findShowCatalogData(
        isEqualTo value: Int
    ) async -> [Show] {
        
        var isDefault: Bool?
        var array = [Show]()
        
        do {
            let querySnapshot = try await self.useDefaultData.getDocuments()
            for document in querySnapshot.documents {
                let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                let decodedObject = try JSONDecoder().decode(UseDefaultData.self, from: jsonData)
                print(decodedObject)
                isDefault = decodedObject.isDefault
            }
        } catch {
            print("\(error)")
        }
        
        if isDefault == true {
            do {
                let querySnapshot = try await self.defaultShow.whereField("type", isEqualTo: value).getDocuments()
                for document in querySnapshot.documents {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    let decodedObject = try JSONDecoder().decode(Show.self, from: jsonData)
                    array.append(decodedObject)
                }
            } catch {
                print("\(error)")
            }
        } else {
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
    
    static func addBulletChatData(
        text: String,
        popTime: Float,
        videoId: String,
        completion: @escaping () -> Void
    ) {
        
        let id = FirestoreManager.bulletChat.document().documentID
        
        let data: [String: Any] = ["bulletChat":
                                    ["chatId": UUID().uuidString,
                                     "content": text,
                                     "contentType": 0,
                                     "popTime": popTime,
                                     "userId": KeychainItem.currentEmail] as [String: Any],
                                   "videoId": videoId,
                                   "id": id]
        
        FirestoreManager.bulletChat.document(id).setData(data) { error in
            if error != nil {
                print("Error adding document: (error)")
            } else {
                completion()
            }
        }
    }
    
    static func getBulletChatData(
        videoId: String,
        completion: @escaping ([BulletChat]) -> Void
    ) {
        var bulletChats = [BulletChat]()
        
        FirestoreManager.bulletChat.whereField(
            "videoId", isEqualTo: videoId
        ).getDocuments { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                        let decodedObject = try JSONDecoder().decode(BulletChatData.self, from: jsonData)
                        bulletChats.append(decodedObject.bulletChat)
                    } catch {
                        print("\(error)")
                    }
                }
                completion(bulletChats)
            }
        }
    }
    
}
