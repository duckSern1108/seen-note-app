//
//  MockNoteListCoordinator.swift
//  SernNoteAppTests
//
//  Created by sonnd on 12/3/25.
//

import UIKit
import Combine
import Domain
@testable import SernNoteApp


class MockNoteListCoordinator: NoteListCoordinator {
    weak var navigationController: UINavigationController?
    
    func goToEditNote(note: NoteModel) -> AnyPublisher<NoteModel, Never> {
        return Just(note).eraseToAnyPublisher()
    }
    
    func goToAddNote() -> AnyPublisher<NoteModel, Never> {
        return Just(NoteModel()).eraseToAnyPublisher()
    }
}
