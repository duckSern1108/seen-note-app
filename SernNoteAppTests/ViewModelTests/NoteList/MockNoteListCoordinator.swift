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
    
    private(set) var didGoToAddNote = false
    private(set) var didGoToEditNote = false
    
    func goToAddNote() -> AnyPublisher<NoteModel, Never> {
        didGoToAddNote = true
        return Just(NoteModel()).eraseToAnyPublisher()
    }
    
    func goToEditNote(note: NoteModel) -> AnyPublisher<NoteModel, Never> {
        didGoToEditNote = true
        return Just(note).eraseToAnyPublisher()
    }
}
