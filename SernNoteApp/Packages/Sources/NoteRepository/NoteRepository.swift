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
    }
    
    public func updateNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        client.publisher(router: NoteRouter.updateNote(data))
    }
    
    public func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        client.publisher(router: NoteRouter.deleteNote(data))
    }
    
    public func getListNote() -> AnyPublisher<[NoteModel], Error> {
        client.publisher(router: NoteRouter.getListNote)
    }
}
