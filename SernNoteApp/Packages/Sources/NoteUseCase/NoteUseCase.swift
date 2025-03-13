import Foundation
import Combine
import Domain

public protocol NoteUseCase {
    func addNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error>
    func updateNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error>
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func getListNote() -> AnyPublisher<[NoteModel], Error>
}
