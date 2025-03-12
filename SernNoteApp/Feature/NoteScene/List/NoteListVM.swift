//
//  ListNote.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import Foundation
import Combine
import Domain
import NoteUseCase


final class NoteListVM: BaseViewModel {
    
    struct Input {
        var searchQueryPublisher: AnyPublisher<String, Never>
        var syncListNotePublisher: AnyPublisher<Void, Never>
        var addNotePublisher: AnyPublisher<Void, Never>
        var selectNotePublisher: AnyPublisher<NoteModel, Never>
        var deleteNotePublisher: AnyPublisher<NoteModel, Never>
    }
    
    struct Output {
        var listNotePubliser: AnyPublisher<[NoteModel], Never>
        
        var loadPubliser: AnyPublisher<Void, Never>
        var editNotePublisher: AnyPublisher<Void, Never>
        var addNotePublisher: AnyPublisher<Void, Never>
        var deleteNotePublisher: AnyPublisher<Void, Never>
    }
    
    let coreDataUseCase: CoreDataNoteUseCase
    let remoteUseCase: NoteUseCase
    let coordinator: NoteListCoordinator
    
    init(coreDataUseCase: CoreDataNoteUseCase, remoteUseCase: NoteUseCase, coordinator: NoteListCoordinator) {
        self.coreDataUseCase = coreDataUseCase
        self.remoteUseCase = remoteUseCase
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        
        let localData = coreDataUseCase.notes
        
        let firstLoadPublisher: AnyPublisher<([NoteModel], [NoteModel]), Never> = input.syncListNotePublisher
            .share()
            .first()
            .flatMap { self.coreDataUseCase.fetchNotes() }
            .replaceError(with: ())
            .withLatestFrom(localData, resultSelector: { $1 })
            .flatMap { localData in
                self.remoteUseCase.getListNote()
                    .replaceError(with: [])
                    .map { (localData, $0) }
            }
            .eraseToAnyPublisher()
        
        let syncRemoteListData: AnyPublisher<[NoteModel], Never> = input.syncListNotePublisher
            .share()
            .dropFirst()
            .flatMap { self.remoteUseCase.getListNote() }
            .replaceError(with: [])
            .eraseToAnyPublisher()
        
        let syncListNoteGeneratorPublisher: AnyPublisher<SyncListNoteModel, Never> = Publishers.Merge(
            firstLoadPublisher,
            syncRemoteListData.withLatestFrom(localData, resultSelector: { ($1, $0) })
        )
            .flatMap { currentData, remoteData in
                SyncListNoteDataGenerator(localData: currentData, remoteData: remoteData)
                    .mergePublisher
            }
            .share()
            .eraseToAnyPublisher()
        
        let syncLocalListPublisher: AnyPublisher<Void, Never> = syncListNoteGeneratorPublisher
            .map { $0.updatedLocalList }
            .flatMap { self.coreDataUseCase.saveNotes($0).replaceError(with: ()) }
            .eraseToAnyPublisher()
        
        
        let updateRemoteListPublisher: AnyPublisher<Void, Never> = syncListNoteGeneratorPublisher
            .flatMap { Publishers.Sequence(sequence: $0.needUpdateRemote) }
            .flatMap { self.remoteUseCase.updateNote($0) }
            .map { _ in }
            .replaceError(with: ())
            .eraseToAnyPublisher()
        
        //MARK: Delete
        let deleteRemoteNotePublisher: AnyPublisher<(data: NoteModel, isDeleteSuccess: Bool), Never> = input.deleteNotePublisher
            .share()
            .filter { $0.hasRemote }
            .flatMap { note in
                var note = note
                note.isDeleteLocal = true
                return self.coreDataUseCase.updateNote(note)
                    .map { _ in (data: note, isDeleteSuccess: true) }
                    .replaceError(with: (data: note, isDeleteSuccess: false))
            }
            .eraseToAnyPublisher()
        
        let deleteLocalNotePublisher: AnyPublisher<Void, Never> = input.deleteNotePublisher
            .share()
            .filter { !$0.hasRemote }
            .flatMap { note in
                return self.coreDataUseCase.deleteNote(note)
                    .replaceError(with: ())
            }
            .eraseToAnyPublisher()
        
        let mergeDeleteRemoteNotePublishers: AnyPublisher<Void, Never> = Publishers
            .Merge(
                deleteRemoteNotePublisher
                    .filter { $0.data.hasRemote && $0.isDeleteSuccess }
                    .map { $0.data },
                syncListNoteGeneratorPublisher
                    .flatMap { Publishers.Sequence(sequence: $0.needDeleteRemote) }
            )
            .flatMap { note in
                self.remoteUseCase.deleteNote(note)
                    .map { _ in note }
                    .eraseToAnyPublisher()
            }
            .flatMap { note in self.coreDataUseCase.deleteNote(note) }
            .map { _ in }
            .replaceError(with: ())
            .eraseToAnyPublisher()
        
        let deleteNotePublisher: AnyPublisher<Void, Never> = Publishers.Merge(
            deleteLocalNotePublisher,
            mergeDeleteRemoteNotePublishers)
            .eraseToAnyPublisher()
        
        //MARK: Add
        let addNotePublisher: AnyPublisher<Void, Never> = Publishers
            .Merge(
                input.addNotePublisher
                    .flatMap { self.coordinator.goToAddNote() }
                    .flatMap { note in
                        self.coreDataUseCase.addNote(note)
                            .map { _ in note }
                            .replaceError(with: note)
                    },
                syncListNoteGeneratorPublisher
                    .flatMap { Publishers.Sequence(sequence: $0.needAddRemote) }
            )
            .flatMap { self.remoteUseCase.addNote($0) }
            .flatMap {
                var note = $0
                note.hasRemote = true
                return self.coreDataUseCase.updateNote(note)
            }
            .replaceError(with: ())
            .eraseToAnyPublisher()
        
        let editNotePublisher: AnyPublisher<Void, Never> = input.selectNotePublisher
            .flatMap { self.coordinator.goToEditNote(note: $0) }
            .flatMap { note in
                self.coreDataUseCase.updateNote(note)
                    .map { _ in note }
                    .replaceError(with: note)
            }
            .flatMap { self.remoteUseCase.updateNote($0) }
            .map { _  -> Void in }
            .replaceError(with: ())
            .eraseToAnyPublisher()
        
        
        let listNotePubliser: AnyPublisher<[NoteModel], Never> = Publishers
            .CombineLatest(
                localData.removeDuplicates(),
                input.searchQueryPublisher
            )
            .flatMap { (list, query) in
                SearchListNoteGenerator(data: list, query: query).searchPublisher
            }
            .eraseToAnyPublisher()
        
        let loadPublisher: AnyPublisher<Void, Never> = Publishers.Merge(
            syncLocalListPublisher,
            updateRemoteListPublisher)
            .eraseToAnyPublisher()
        
        return Output(
            listNotePubliser: listNotePubliser,
            loadPubliser: loadPublisher,
            editNotePublisher: editNotePublisher,
            addNotePublisher: addNotePublisher,
            deleteNotePublisher: deleteNotePublisher)
    }
}

extension NoteListVM {
    func bindSyncDataAction(input: Input, cancellations: inout Set<AnyCancellable>) {
        
    }
    
    func bindSelectAction(input: Input, cancellations: inout Set<AnyCancellable>) {
        
    }
}
