//
//  HomeRequest.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/13.
//

import Foundation

class YouTubeParameter {
    
    static let shared = YouTubeParameter()
    
    var channelID: String = ""
    var playlistId: String = ""
    var nextPageToken: String = ""
    var part: String = "snippet"
    var maxResults: Int = 25
}

enum YoutubeRequest: Request {
    
    case channel
    case show
    case playlistItems(playlistId: String)
    case hot
    case nextPageToken
    
    var headers: [String: String]? {
        switch self {
        case .channel, .show, .playlistItems, .hot:
            return [
                HTTPHeaderField.auth.rawValue: "\(Constant.YOUR_ACCESS_TOKEN)",
                HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue
            ]
        case .nextPageToken:
            return [
                HTTPHeaderField.auth.rawValue: "\(Constant.YOUR_ACCESS_TOKEN)"
            ]
        }
    }
    
    var body: Data? {
        switch self {
        case .channel: return nil
        case .show: return nil
        case .playlistItems: return nil
        case .hot: return nil
        case .nextPageToken: return nil
        }
    }
    
    var method: String {
        switch self {
        case .channel, .show, .playlistItems, .hot, .nextPageToken: return HTTPMethod.GET.rawValue
        }
    }
    
    var endPoint: String {
        switch self {
        case .channel:
            
            return "/channels?part=\(YouTubeParameter.shared.part)"
            + "&id=\(YouTubeParameter.shared.channelID)"
            + "&key=\(Constant.API_KEY)"
            
        case .show:
            
            return "/playlists?part=\(YouTubeParameter.shared.part)"
            + "&channelId=\(YouTubeParameter.shared.channelID)"
            + "&maxResults=\(YouTubeParameter.shared.maxResults)"
            + "&key=\(Constant.API_KEY)"
            
        case .playlistItems:
            
            return "/playlistItems?part=\(YouTubeParameter.shared.part)"
            + "&playlistId=\(YouTubeParameter.shared.playlistId)"
            + "&maxResults=\(YouTubeParameter.shared.maxResults)"
            + "&key=\(Constant.API_KEY)"
            
        case .hot:
            
            return "/videos?part=\(YouTubeParameter.shared.part)"
            + "%2CcontentDetails%2Cstatistics&chart=mostPopular"
            + "&maxResults=\(YouTubeParameter.shared.maxResults)&regionCode=TW"
            + "&key=\(Constant.API_KEY)"
            
        case .nextPageToken:
            
            return "/playlistItems?part=\(YouTubeParameter.shared.part)"
            + "&maxResults=\(YouTubeParameter.shared.maxResults)"
            + "&pageToken=\(YouTubeParameter.shared.nextPageToken)"
            + "&playlistId=\(YouTubeParameter.shared.playlistId)"
            + "&key=\(Constant.API_KEY)"
            
        }
    }
}
