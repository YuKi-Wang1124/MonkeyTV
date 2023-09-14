//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/14.
//

import Foundation

struct PlaylistListResponse: Codable {
//    let kind: String
//    let etag: String
//    let nextPageToken: String
//    let pageInfo: PageInfo
    let items: [Playlist]
}

struct Playlist: Codable {
//    let kind: String
//    let etag: String
    let id: String
    let snippet: PlaylistSnippet
}

struct PlaylistSnippet: Codable {
//    let publishedAt: String
//    let channelId: String
    let title: String
//    let description: String
    let thumbnails: Thumbnails
//    let channelTitle: String
//    let localized: Localized
}


