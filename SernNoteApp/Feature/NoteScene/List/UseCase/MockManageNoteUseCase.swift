//
//  CoreDataManageNoteUseCase.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import Foundation
import Combine


class MockManageNoteUseCase: ManageNoteUseCase {
    func addNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        Just(data)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        Just(data)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getListNote() -> AnyPublisher<[NoteModel], Error> {
        Just(NoteModel.mock)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
