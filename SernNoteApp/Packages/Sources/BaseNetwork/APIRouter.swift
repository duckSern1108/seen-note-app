//
//  APIRouter.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import Foundation
import Combine


public protocol APIRouter {
    func path() -> String
    func method() -> HTTPMethod
    func domain() -> ServerDomain
    func params() -> [String: Any]
    func headers() -> [String: String]
}

public extension APIRouter {
    func headers() -> [String: String] {
        [:]
    }
}

extension APIRouter {
    func urlRequest() throws -> URLRequest {
        guard let url = URL(string: domain().rawValue + path()) else {
            throw APIError.routerNotValid
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let param = params()
        //TODO: Get query param
        if !param.isEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: params())
        }
        
        request.httpMethod = method().rawValue
        request.allHTTPHeaderFields = headers()
        return request
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum APIError: LocalizedError {
    case routerNotValid
    case decodeFail
    case serverError(msg: String, code: Int)
    
    public var errorDescription: String? {
        switch self {
        case .routerNotValid:
            return "Some thing went wrong when building request"
        case .decodeFail:
            return "Can not decode data"
        case .serverError(let msg, _):
            return msg
        }
    }
}
