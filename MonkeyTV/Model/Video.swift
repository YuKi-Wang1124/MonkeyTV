//
//  Video.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/13.
//

import Foundation

struct Video: Codable {
    var videoId: String
    var title: String
    var description: String
    var thumbnail: String
    var published: String
}

struct MKShow: Hashable {
    var id: String
    var videoId: String 
    var image: String
    var title: String
    var playlistId: String
}

struct SuccessParser<T: Codable>: Codable {
    let data: T
    let paging: Int?
    enum CodingKeys: String, CodingKey {
        case data
        case paging = "next_paging"
    }
}

struct FailureParser: Codable {
    let errorMessage: String
}

struct Model: Hashable {
    var text: String
    var image: String
}
