//
//  NetworkClient.swift
//  Packages
//
//  Created by sonnd on 11/3/25.
//

import Foundation
import Combine

public struct NetworkClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func publisher<T: Codable>(type: T.Type, router: APIRouter) -> AnyPublisher<T, Error> {
        do {
            let urlRequest = try router.urlRequest()
            return session.dataTaskPublisher(for: urlRequest)
                .mapError { error in
                    APIError.serverError(msg: error.localizedDescription, code: error.errorCode)
                }
                .tryMap { (data, reponse) -> T in
                    try JSONDecoder().decode(type, from: data)
                }
                .eraseToAnyPublisher()
        }
        catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    public func publisher(router: APIRouter) -> AnyPublisher<Void, Error> {
        do {
            let urlRequest = try router.urlRequest()
            return session.dataTaskPublisher(for: urlRequest)
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
