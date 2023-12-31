//
//  HTTPClient.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/13.
//

import Foundation
import UIKit

enum Result<T> {
    case success(T)
    case failure(Error)
}

enum HTTPClientError: Error {
    case decodeDataFail
    case clientError(Data)
    case serverError
    case unexpectedError
}

enum HTTPMethod: String {
    case GET
    case POST
}

enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case auth = "Authorization"
}

enum HTTPHeaderValue: String {
    case json = "application/json"
}

protocol Request {
    var headers: [String: String]? { get }
    var body: Data? { get }
    var method: String { get }
    var endPoint: String { get }
}

extension Request {
    func makeRequest() -> URLRequest {
        let urlString = Bundle.valueForString(key: Constant.urlKey) + endPoint
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        request.httpMethod = method
        return request
    }
}

class HTTPClientManager {

    static let shared = HTTPClientManager()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let cache = NSCache<NSString, NSData>()

    private init() {}

    func request(
        _ request: Request,
        completion: @escaping (Result<Data>) -> Void
    ) {
        
        if let cache = cache.object(forKey: request.endPoint as NSString) {
            completion(Result.success(cache as Data))
            return
        }
        
        URLSession.shared.dataTask(
            with: request.makeRequest(),
            completionHandler: { (data, response, error) in
                if let error = error {
                    return completion(Result.failure(error))
                }
                // swiftlint:disable force_cast
                let httpResponse = response as! HTTPURLResponse
                // swiftlint:enable force_cast
                let statusCode = httpResponse.statusCode
                switch statusCode {
                case 200..<300:
                    self.cache.setObject(data! as NSData, forKey: request.endPoint as NSString)
                    print("StatusCode: \(statusCode)")
                    completion(Result.success(data!))
                case 400..<500:
                    print("StatusCode: \(statusCode)")
                    completion(Result.failure(HTTPClientError.clientError(data!)))
                case 500..<600:
                    print("StatusCode: \(statusCode)")
                    completion(Result.failure(HTTPClientError.serverError))
                default:
                    print("StatusCode: \(statusCode)")
                    completion(Result.failure(HTTPClientError.unexpectedError))
                }
            }).resume()
    }
    
    func getYouTubeVideoData(
        complettion: @escaping ([Playlist]) -> Void
    ) {
        HTTPClientManager.shared.request(
            YoutubeRequest.playlistItems(
                playlistId: YouTubeParameter.shared.playlistId),
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    do {
                        let info = try JSONDecoder().decode(PlaylistListResponse.self, from: data)
                        YouTubeParameter.shared.nextPageToken = info.nextPageToken
                        complettion(info.items)
                    } catch {
                        print(Result<Any>.failure(error))
                    }
                case .failure(let error):
                    print(Result<Any>.failure(error))
                }
            })
    }
}
