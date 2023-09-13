//
//  HomeRequest.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/13.
//

import Foundation

enum HomeRequest: Request {
    case hots
    case women(paging: Int)
    case men(paging: Int)
    case accessories(paging: Int)

    var headers: [String: String] {
        switch self {
        case .hots, .women, .men, .accessories: return [:]
        }
    }

    var body: Data? {
        switch self {
        case .hots, .women, .men, .accessories: return nil
        }
    }

    var method: String {
        switch self {
        case .hots, .women, .men, .accessories: return HTTPMethod.GET.rawValue
        }
    }

    var endPoint: String {
        switch self {
        case .hots: return "/marketing/hots"
        case .women(let paging): return "/products/women?paging=\(paging)"
        case .men(let paging): return "/products/men?paging=\(paging)"
        case .accessories(let paging): return "/products/accessories?paging=\(paging)"
        }
    }
}
