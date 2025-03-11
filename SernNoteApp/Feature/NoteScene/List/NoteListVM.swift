//
//  ListNote.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import Foundation
import Combine


final class NoteListVM: BaseViewModel {
    
    struct Input {
        var searchQuery: AnyPublisher<String, Never>
        var syncListNotePublisher: AnyPublisher<Void, Never>
        var addNotePublisher: AnyPublisher<Void, Never>
        var selectNotePublisher: AnyPublisher<NoteModel, Never>
        var deleteNotePublisher: AnyPublisher<NoteModel, Never>
    }
    
    struct Output {
        var listNotePubliser: AnyPublisher<[NoteModel], Never>
        
        var firstLoadLocalPublisher: AnyPublisher<Void, Error>
        var syncLocalListPublisher: AnyPublisher<Void, Error>
        var updateRemoteListPublisher: AnyPublisher<Void, Error>
        var editNotePublisher: AnyPublisher<Void, Error>
        var addNotePublisher: AnyPublisher<Void, Error>
        var deleteNotePublisher: AnyPublisher<Void, Error>
    }
    
    let coreDataUseCase: CoreDataManageNoteUseCase
    let remoteUseCase: ManageNoteUseCase
    let coordinator: NoteListCoordinator
    
    init(coreDataUseCase: CoreDataManageNoteUseCase, remoteUseCase: ManageNoteUseCase, coordinator: NoteListCoordinator) {
        self.coreDataUseCase = coreDataUseCase
        self.remoteUseCase = remoteUseCase
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        
        let localData = coreDataUseCase.notes
        
        let firstLocalData = localData.first()
        
        let getRemoteListData = input.syncListNotePublisher
            .share()
            .flatMap { self.remoteUseCase.getListNote() }
            .replaceError(with: [])
            .eraseToAnyPublisher()
        
        let firstLoadLocalPublisher: AnyPublisher<Void, Error> = input.syncListNotePublisher
            .share()
            .first()
            .flatMap { self.coreDataUseCase.fetchNotes() }
            .eraseToAnyPublisher()
        
        let syncListNoteGeneratorPublisher = Publishers.Merge(
            firstLocalData
                .withLatestFrom(getRemoteListData, resultSelector: { ($0, $1) }),
            getRemoteListData.withLatestFrom(localData, resultSelector: { ($1, $0) }))
            .flatMap { currentData, remoteData in
                SyncListNoteDataGenerator(localData: currentData, remoteData: remoteData)
                    .mergePublisher
            }
            .share()
        
        let syncLocalListPublisher = syncListNoteGeneratorPublisher
            .map { $0.updatedLocalList }
            .flatMap { self.coreDataUseCase.saveNotes($0) }
            .eraseToAnyPublisher()
        
        
        let updateRemoteListPublisher: AnyPublisher<Void, Error> = syncListNoteGeneratorPublisher
            .flatMap { Publishers.Sequence(sequence: $0.needUpdateRemote) }
            .flatMap { self.remoteUseCase.updateNote($0) }
            .map { _ in }
            .eraseToAnyPublisher()
        
        //MARK: Delete
        let deleteLocalPublisher: AnyPublisher<NoteModel, Error> = input.deleteNotePublisher
            .share()
            .flatMap { note in
                var note = note
                note.isDeleteLocal = true
                return self.coreDataUseCase.updateNote(note)
                    .map { _ in note }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        let mergeDeleteLocalPublishers = Publishers
            .Merge(
                deleteLocalPublisher
                    .filter { $0.hasRemote },
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
            .eraseToAnyPublisher()
        
        //MARK: Add
        let addNotePublisher: AnyPublisher<Void, Error> = Publishers
            .Merge(
                input.addNotePublisher
                    .flatMap { self.coordinator.goToAddNote() }
                    .flatMap { note in self.coreDataUseCase.addNote(note).map { _ in note} },
                syncListNoteGeneratorPublisher
                    .flatMap { Publishers.Sequence(sequence: $0.needAddRemote) }
            )
            .flatMap { self.remoteUseCase.addNote($0) }
            .flatMap {
                var note = $0
                note.hasRemote = true
                return self.coreDataUseCase.updateNote(note)
            }
            .eraseToAnyPublisher()
        
        let editNotePublisher: AnyPublisher<Void, Error> = input.selectNotePublisher
            .flatMap { self.coordinator.goToEditNote(note: $0) }
            .flatMap {
                Publishers.Zip(self.coreDataUseCase.updateNote($0), self.remoteUseCase.updateNote($0))
            }
            .map { _  -> Void in }
            .eraseToAnyPublisher()
            
        
        let listNotePubliser: AnyPublisher<[NoteModel], Never> = Publishers
            .CombineLatest(
                localData.removeDuplicates(),
                input.searchQuery
            )
            .flatMap { (list, query) in
                SearchListNoteOperator(data: list, query: query).searchPublisher
            }
            .eraseToAnyPublisher()
        
        return Output(
            listNotePubliser: listNotePubliser,
            firstLoadLocalPublisher: firstLoadLocalPublisher,
            syncLocalListPublisher: syncLocalListPublisher,
            updateRemoteListPublisher: updateRemoteListPublisher,
            editNotePublisher: editNotePublisher,
            addNotePublisher: addNotePublisher,
            deleteNotePublisher: mergeDeleteLocalPublishers)
    }
}

extension NoteListVM {
    func bindSyncDataAction(input: Input, cancellations: inout Set<AnyCancellable>) {
        
    }
    
    func bindSelectAction(input: Input, cancellations: inout Set<AnyCancellable>) {
        
    }
}
