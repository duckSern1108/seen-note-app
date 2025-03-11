//
//  APIRouter.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import Foundation
import Combine


protocol APIRouter {
    func path() -> String
    func method() -> HTTPMethod
    func baseURL() -> String
    func params() -> [String: Any]
    func headers() -> [String: String?]
}

extension APIRouter {
    func baseURL() -> String {
        return ""
    }
    
    func headers() -> [String: String?] {
        [:]
    }
}

extension APIRouter {
    func urlRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL() + path()) else {
            throw APIError.routerNotValid
        }
        var request = URLRequest(url: url)
        let headers = headers()
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let param = params()
        //TODO: Get query param
        if !param.isEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: params())
        }
        
        request.httpMethod = method().rawValue
        return request
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum APIError: LocalizedError {
    case routerNotValid
    case decodeFail
    case serverError(msg: String, code: Int)
    
    var errorDescription: String? {
        switch self {
        case .routerNotValid:
            return "Đã có lỗi xảy ra"
        case .decodeFail:
            return "Server trả về sai format"
        case .serverError(let msg, _):
            return msg
        }
    }
}

extension APIRouter {
    func anyPublisher<T: Codable>() -> AnyPublisher<T, Error> {
        do {
            let urlRequest = try self.urlRequest()
            return URLSession.shared.dataTaskPublisher(for: urlRequest)
                .mapError { error in
                    APIError.serverError(msg: error.localizedDescription, code: error.errorCode)
                }
                .tryMap { (data, reponse) -> T in
                    try JSONDecoder().decode(T.self, from: data)
                }
                .eraseToAnyPublisher()
        }
        catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func anyPublisher() -> AnyPublisher<Void, Error> {
        do {
            let urlRequest = try self.urlRequest()
            return URLSession.shared.dataTaskPublisher(for: urlRequest)
                .mapError { error in
                    APIError.serverError(msg: error.localizedDescription, code: error.errorCode)
                }
                .map { _ in }
                .eraseToAnyPublisher()
        }
        catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
