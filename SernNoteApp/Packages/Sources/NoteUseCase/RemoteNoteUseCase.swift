//
//  RemoteManageNoteUseCase.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import Foundation
import Combine
import Domain
import APIRouter


public class RemoteNoteUseCase: NoteUseCase {
    
    public init() {}
    
    public func addNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        NoteRouter.addNote(data)
            .publisher()
    }
    
    public func updateNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        NoteRouter.updateNote(data)
            .publisher()
    }
    
    public func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        NoteRouter.addNote(data)
            .publisher()
    }
    
    public func getListNote() -> AnyPublisher<[NoteModel], Error> {
        NoteRouter.getListNote
            .publisher()
    }
}

