//
//  HomeRequest.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/13.
//

import Foundation

enum YoutubeRequest: Request {
    case channel
    case show
    case playlistItems(playlistId: String)

    var headers: [String: String] {
        switch self {
        case .channel, .show, .playlistItems: return [
            HTTPHeaderField.auth.rawValue: "\(Constant.YOUR_ACCESS_TOKEN)",
            HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue
        ]
        }
    }

    var body: Data? {
        switch self {
        case .channel: return nil
        case .show: return nil
        case .playlistItems: return nil
        }
    }

    var method: String {
        switch self {
        case .channel, .show, .playlistItems: return HTTPMethod.GET.rawValue
        }
    }

    var endPoint: String {
        switch self {
        case .channel:
            return "/channels?part=snippet&id=\(YouTubeParameter.shared.channelID)&key=\(Constant.API_KEY)"
        case .show:
            return "/playlists?part=snippet&channelId=\(YouTubeParameter.shared.channelID)&maxResults=50&key=\(Constant.API_KEY)"
        case .playlistItems:
            return "/playlistItems?part=snippet&playlistId=\(YouTubeParameter.shared.playlistId)&key=\(Constant.API_KEY)"
        }
   }
}

class YouTubeParameter {
    static let shared = YouTubeParameter()
    var channelID: String = "UCAqzHNzLTC6Vm5UYE7xw_2A"
    var playlistId: String = ""
}
