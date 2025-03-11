//
//  NoteListCoordinator.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import UIKit
import Combine


protocol NoteListCoordinator {
    var navigationController: UINavigationController? { get set }
    
    func goToEditNote(note: NoteModel) -> AnyPublisher<NoteModel, Never>
    func goToAddNote() -> AnyPublisher<NoteModel, Never>
}

class NoteListCoordinatorDefault: NoteListCoordinator {
    weak var navigationController: UINavigationController?
    
    func goToEditNote(note: NoteModel) -> AnyPublisher<NoteModel, Never> {
        let vm = SingleNoteVM(note: note)
        let vc = SingleNoteVC.newVC(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
        return vm.delegate.eraseToAnyPublisher()
    }
    
    func goToAddNote() -> AnyPublisher<NoteModel, Never> {
        let vm = SingleNoteVM(note: NoteModel())
        let vc = SingleNoteVC.newVC(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
        return vm.delegate.eraseToAnyPublisher()
    }
}
