//
//  HomeRequest.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/13.
//

import Foundation

enum HomeRequest: Request {
    case channel
    case show
    case men(paging: Int)
    case accessories(paging: Int)

    var headers: [String: String] {
        switch self {
        case .channel, .show: return [
            HTTPHeaderField.auth.rawValue: "\(Constant.YOUR_ACCESS_TOKEN)",
            HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue
        ]
        case .men: return [:]
        case .accessories: return [:]
        }
    }

    var body: Data? {
        switch self {
        case .channel: return nil
        case .show: return nil
        case .men: return nil
        case .accessories: return nil
        }
    }

    var method: String {
        switch self {
        case .channel, .show, .men, .accessories: return HTTPMethod.GET.rawValue
        }
    }

    var endPoint: String {
        switch self {
        case .channel: return "/channels?part=snippet&id=\(channelID)&key=\(Constant.API_KEY)"
        case .show: return "/playlists?part=snippet&channelId=\(channelID)&maxResults=50&key=\(Constant.API_KEY)"
        case .men(let paging): return "/products/men?paging=\(paging)"
        case .accessories(let paging): return "/products/accessories?paging=\(paging)"
        }
   }
}

let channelID = "UCCPYSMEnbeepGM7RU6qxyUA"
