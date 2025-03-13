//
//  MockRemoteNoteUseCase.swift
//  SernNoteAppTests
//
//  Created by sonnd on 12/3/25.
//

import Foundation
import Combine
import Domain
import NoteUseCase

final class MockRemoteNoteUseCase: NoteUseCase {
    private(set) var addNoteCalled = false
    private(set) var updateNoteCalled = false
    private(set) var deleteNoteCalled = false
    private(set) var getListNoteCalled = false
    
    func addNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        addNoteCalled = true
        return Just(data).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func updateNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        updateNoteCalled = true
        return Just(data).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        deleteNoteCalled = true
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getListNote() -> AnyPublisher<[NoteModel], Error> {
        getListNoteCalled = true
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
