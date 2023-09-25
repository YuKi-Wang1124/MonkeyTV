//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/14.
//

import Foundation

struct ChannelResponse: Codable {
    let kind: String
    let etag: String
    let pageInfo: PageInfo
    let items: [ChannelItem]
}

struct PageInfo: Codable {
    let totalResults: Int
    let resultsPerPage: Int
}

struct ChannelItem: Codable {
    let kind: String
    let etag: String
    let id: String
    let snippet: ChannelSnippet
}

struct ChannelSnippet: Codable {
    let title: String
    let description: String
    let customUrl: String
    let publishedAt: String
    let thumbnails: Thumbnails
    let localized: Localized
    let country: String
}

struct Thumbnails: Codable {
    let `default`: Thumbnail
//    let medium: Thumbnail
//    let high: Thumbnail
}

struct Thumbnail: Codable {
    let url: String
//    let width: Int
//    let height: Int
}

struct Localized: Codable {
    let title: String
    let description: String
}






struct PlaylistListResponse: Codable, Hashable {
    let kind: String
    let etag: String
    let nextPageToken: String
    let pageInfo: PageInfo
    let items: [Playlist]
    static func == (lhs: PlaylistListResponse, rhs: PlaylistListResponse) -> Bool {
        true
    }
    func hash(into hasher: inout Hasher) {
    }
}

struct Playlist: Codable, Hashable {
    let kind: String
    let etag: String
    let id: String
    let snippet: Snippet

    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
         lhs.id == rhs.id        
    }
    
    func hash(into hasher: inout Hasher) {
    }
}

struct PlaylistSnippet: Codable {
    let publishedAt: String
    let channelId: String
    let title: String
    let description: String
    let thumbnails: Thumbnails
    let channelTitle: String
    let localized: Localized?
}

struct PlaylistItem: Codable {
    let kind: String
    let etag: String
    let id: String
    let snippet: Snippet
}

struct Snippet: Codable {
    let publishedAt: String
    let channelId: String
    let title: String
    let description: String
    let thumbnails: Thumbnails
    let channelTitle: String
    let playlistId: String
    let position: Int
    let resourceId: ResourceId
    let videoOwnerChannelTitle: String
    let videoOwnerChannelId: String
}

struct ResourceId: Codable {
    let kind: String
    let videoId: String
}



