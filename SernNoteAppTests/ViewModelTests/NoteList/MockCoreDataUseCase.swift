//
//  MockCoreDataUseCase.swift
//  SernNoteAppTests
//
//  Created by sonnd on 12/3/25.
//

import Foundation
import Combine
import Domain
import NoteUseCase

final class MockCoreDataUseCase: CoreDataNoteUseCase {
    private(set) var addNoteCalled = false
    private(set) var updateNoteCalled = false
    private(set) var deleteNoteCalled = false
    private(set) var fetchListNoteCalled = false
    private(set) var saveListNoteCalled = false
    private let _notes: CurrentValueSubject<[NoteModel], Never> = .init([])
    
    var notes: AnyPublisher<[NoteModel], Never> { _notes.eraseToAnyPublisher() }
    
    func addNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        addNoteCalled = true
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func updateNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        updateNoteCalled = true
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        deleteNoteCalled = true
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func fetchNotes() -> AnyPublisher<Void, Error> {
        fetchListNoteCalled = true
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func saveNotes(_ datas: [NoteModel]) -> AnyPublisher<Void, Error> {
        saveListNoteCalled = true
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
