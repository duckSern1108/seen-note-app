import Foundation
import Combine
import Domain
import BaseNetwork



public protocol NoteRepository {
    func addNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error>
    func updateNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error>
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func getListNote() -> AnyPublisher<[NoteModel], Error>
}


public class NoteRepositoryDefault: NoteRepository {
    
    private let client: NetworkClient
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
    public func addNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        client.publisher(router: NoteRouter.addNote(data))
            .map { _ in data }
            .eraseToAnyPublisher()
    }
    
    public func updateNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        client.publisher(router: NoteRouter.updateNote(data))
            .map { _ in data }
            .eraseToAnyPublisher()
    }
    
    public func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        client.publisher(router: NoteRouter.deleteNote(data))
    }
    
    public func getListNote() -> AnyPublisher<[NoteModel], Error> {
        client.publisher(type: [NoteModelResponse].self, router: NoteRouter.getListNote)
            .map { list in list.map { $0.noteModel } }
            .eraseToAnyPublisher()
    }
}

private extension NoteRepositoryDefault {
    struct NoteModelResponse: Codable {
        var id: Int = 0
        var title: String = ""
        var content: String = ""
        var created: Double = 0.0
        var lastUpdated: Double = 0.0
    }
}

private extension NoteRepositoryDefault.NoteModelResponse {
    var noteModel: NoteModel {
        .init(
            hasRemote: true,
            isDeleteLocal: false,
            title: title,
            content: content,
            created: Date(timeIntervalSince1970: created),
            lastUpdated: Date(timeIntervalSince1970: lastUpdated))
    }
}
