//
//  RemoteManageNoteUseCase.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import Foundation
import Combine


class RemoteManageNoteUseCase: ManageNoteUseCase {
    
    func addNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        NoteRouter.addNote(data)
            .anyPublisher()
    }
    
    func updateNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        NoteRouter.updateNote(data)
            .anyPublisher()
    }
    
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        NoteRouter.addNote(data)
            .anyPublisher()
    }
    
    func getListNote() -> AnyPublisher<[NoteModel], Error> {
        NoteRouter.getListNote
            .anyPublisher()
    }
}

