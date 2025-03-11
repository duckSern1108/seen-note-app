//
//  RemoteManageNoteUseCase.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import Foundation
import Combine
import Domain
import NoteRepository


public class RemoteNoteUseCase: NoteUseCase {
    
    private let repository: NoteRepository
    
    public init(repository: NoteRepository) {
        self.repository = repository
    }
    
    public func addNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        repository.addNote(data)
    }
    
    public func updateNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        repository.updateNote(data)
    }
    
    public func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        repository.deleteNote(data)
    }
    
    public func getListNote() -> AnyPublisher<[NoteModel], Error> {
        repository.getListNote()
    }
}

