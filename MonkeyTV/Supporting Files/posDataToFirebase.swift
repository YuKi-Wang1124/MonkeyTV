//
//  posDataToFirebase.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/22.
//

import Foundation

//let id = FirestoreManageer.show.document().documentID
//let data: [String: Any] =
//["type": 5,
// "image": $0.snippet.thumbnails.medium.url,
// "showName": $0.snippet.title,
// "playlistId": $0.id,
// "id": id]
//FirestoreManageer.show.document(id).setData(data) { error in
//    if error != nil {
//        print("Error adding document: (error)")
//    } else {
//
//    }
//}

//    // MARK: - call api to get images and titles
//    func getVideoCover(request: Request) {
//        let decoder = JSONDecoder()
//        HTTPClient.shared.request(request, completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let data):
//                do {
//                    let info = try decoder.decode(PlaylistListResponse.self, from: data)
//                    info.items.forEach({
//                        let show = MKShow(image: $0.snippet.thumbnails.medium.url,
//                                          title: $0.snippet.title, playlistId: $0.id)
////                        self.model.append(show)
//                        //                        print($0.id)
////                        self.snapshot.appendItems([show], toSection: .main)
////                        self.dataSource.apply(self.snapshot)
//
//                    })
//                } catch {
//                    print(Result<Any>.failure(error))
//                }
//            case .failure(let error):
//                print(Result<Any>.failure(error))
//            }
//        })
//    }

//    func getVideoCover(request: Request) {
//        let decoder = JSONDecoder()
//        HTTPClient.shared.request(request, completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let data):
//                do {
//                    let info = try decoder.decode(PlaylistListResponse.self, from: data)
//                    info.items.forEach({
//                        let show = MKShow(image: $0.snippet.thumbnails.medium.url,
//                                          title: $0.snippet.title,
//                                          playlistId: $0.id)
//                        DispatchQueue.main.async {
//                            self.snapshot.appendItems([show], toSection: .main)
//                            self.dataSource.apply(self.snapshot)
//                            self.collectionView.reloadData()
//                        }
//                    })
//                } catch {
//                    print(Result<Any>.failure(error))
//                }
//            case .failure(let error):
//                print(Result<Any>.failure(error))
//            }
//        })
//    }
