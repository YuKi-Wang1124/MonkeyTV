//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/14.
//

import Foundation

struct ChannelResponse: Codable {
//    let kind: String
//    let etag: String
//    let pageInfo: PageInfo
    let items: [ChannelItem]
}

struct PageInfo: Codable {
    let totalResults: Int
    let resultsPerPage: Int
}

struct ChannelItem: Codable {
//    let kind: String
//    let etag: String
    let id: String
    let snippet: ChannelSnippet
}

struct ChannelSnippet: Codable {
    let title: String
//    let description: String
    let customUrl: String
//    let publishedAt: String
    let thumbnails: Thumbnails
//    let localized: Localized
//    let country: String
}

struct Thumbnails: Codable {
//    let `default`: Thumbnail
    let medium: Thumbnail
//    let high: Thumbnail
}

struct Thumbnail: Codable {
    let url: String
    let width: Int
    let height: Int
}

struct Localized: Codable {
    let title: String
    let description: String
}
