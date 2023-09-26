//
//  UserRequest.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/13.
//

import Foundation

enum UserRequest: Request {
    case signin(String)
    case checkout(token: String, body: Data?)
    case profile(token: String)

    var headers: [String: String] {
        switch self {
        case .signin:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .checkout(let token, _):
            return [
                HTTPHeaderField.auth.rawValue: "Bearer \(token)",
                HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue
            ]
        case .profile(let token):
            return [
                HTTPHeaderField.auth.rawValue: "Bearer \(token)",
                HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue
            ]
        }
    }

    var body: Data? {
        switch self {
        case .signin(let token):
            let dict = [
                "provider": "facebook",
                "access_token": token
            ]
            return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        case .checkout(_, let body):
            return body
        case .profile: return nil
        }
    }

    var method: String {
        switch self {
        case .signin, .checkout: return HTTPMethod.POST.rawValue
        case .profile: return HTTPMethod.GET.rawValue
        }
    }

    var endPoint: String {
        switch self {
        case .signin: return "/user/signin"
        case .checkout: return "/order/checkout"
        case .profile: return "/user/profile"
        }
    }
}


