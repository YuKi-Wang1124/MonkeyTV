//
//  HTTPClient.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/13.
//

import Foundation

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
    var headers: [String: String] { get }
    var body: Data? { get }
    var method: String { get }
    var endPoint: String { get }
}

extension Request {
    func makeRequest() -> URLRequest {
        let urlString = Bundle.valueForString(key: Constant.urlKey) + endPoint
        print(Bundle.valueForString(key: Constant.urlKey) + endPoint)
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        request.httpMethod = method
        return request
    }
}

class HTTPClient {

    static let shared = HTTPClient()

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var cache = [String: Data]()

    private init() {}

    func request(
        _ request: Request,
        completion: @escaping (Result<Data>) -> Void
    ) {
        let cacheData = cache[request.endPoint]
        if cacheData != nil {
            completion(Result.success(cacheData!))
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
                    self.cache[request.endPoint] = data
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
}
