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
    
    let localUseCase: ManageNoteUseCase
    let remoteUseCase: ManageNoteUseCase
    let coordinator: NoteListCoordinator
    
    @Published private(set) var listNote: [NoteModel] = []
    
    @Published private var localData: [NoteModel] = []
    
    init(localUseCase: ManageNoteUseCase, remoteUseCase: ManageNoteUseCase, coordinator: NoteListCoordinator) {
        self.localUseCase = localUseCase
        self.remoteUseCase = remoteUseCase
        self.coordinator = coordinator
    }
    
    func bind(input: Input, cancellations: inout Set<AnyCancellable>) {
        Publishers.CombineLatest(
            $localData.removeDuplicates(),
            input.searchQuery
        )
        .flatMap { (list, query) in
            SearchListNoteOperator(data: list, query: query).searchPublisher
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$listNote)
        
        bindSyncDataAction(input: input, cancellations: &cancellations)
        bindSelectAction(input: input, cancellations: &cancellations)
    }
}

extension NoteListVM {
    func bindSyncDataAction(input: Input, cancellations: inout Set<AnyCancellable>) {
        let firstGetLocalData = input.syncListNotePublisher
            .share()
            .first()
            .flatMap { self.localUseCase.getListNote() }
            .replaceError(with: [])
        
        let getRemoteListData = input.syncListNotePublisher
            .share()
            .flatMap { self.remoteUseCase.getListNote() }
            .replaceError(with: [])
            .eraseToAnyPublisher()
        
        firstGetLocalData.assign(to: &$localData)
        
        let syncListNoteGeneratorPublisher = Publishers.Merge(
            firstGetLocalData
                .withLatestFrom(getRemoteListData, resultSelector: { ($0, $1) }),
            getRemoteListData.withLatestFrom($localData, resultSelector: { ($1, $0) }))
            .flatMap { currentData, remoteData in
                SyncListNoteDataGenerator(localData: currentData, remoteData: remoteData)
                    .mergePublisher
            }
            .share()
        
        syncListNoteGeneratorPublisher
            .map { $0.syncList }
            .assign(to: &$localData)
        
        syncListNoteGeneratorPublisher
            .flatMap { Publishers.Sequence(sequence: $0.needAddLocal) }
            .flatMap { self.localUseCase.addNote($0) }
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellations)
        
        syncListNoteGeneratorPublisher
            .flatMap { Publishers.Sequence(sequence: $0.needUpdateLocal) }
            .flatMap { self.localUseCase.updateNote($0) }
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellations)
        
        
        syncListNoteGeneratorPublisher
            .flatMap { Publishers.Sequence(sequence: $0.needUpdateRemote) }
            .flatMap { self.remoteUseCase.updateNote($0) }
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellations)
        
        
        //MARK: Delete
        
        let deleteLocalPublisher = input.deleteNotePublisher
            .share()
            .flatMap { note -> AnyPublisher<NoteModel, Never> in
                var note = note
                note.isDeleteLocal = true
                return self.localUseCase.updateNote(note)
                    .replaceError(with: note)
                    .setFailureType(to: Never.self)
                    .eraseToAnyPublisher()
            }
            .share()
        
        deleteLocalPublisher
            .withLatestFrom($localData, resultSelector: {
                ($0, $1)
            })
            .map { (note, list) in
                guard let index = list.firstIndex(where: { $0.created == note.created }) else { return [] }
                var list = list
                list[index] = note
                return list
            }
            .assign(to: &$localData)
        
        let mergeDeleteLocalPublishers = Publishers
            .Merge3(
                deleteLocalPublisher
                    .filter { $0.hasRemote }
                    .flatMap { note in
                        self.remoteUseCase.deleteNote(note)
                            .map { _ in note }
                            .eraseToAnyPublisher()
                    },
                syncListNoteGeneratorPublisher
                    .flatMap { Publishers.Sequence(sequence: $0.needDeleteRemote) }
                    .flatMap { note in
                        self.remoteUseCase.deleteNote(note)
                            .map { _ in note }
                            .eraseToAnyPublisher()
                    },
                syncListNoteGeneratorPublisher
                    .flatMap { Publishers.Sequence(sequence: $0.needDeleteLocal) }
                    .eraseToAnyPublisher()
            )
        mergeDeleteLocalPublishers
            .flatMap { note in
                self.localUseCase.deleteNote(note)
                    .map { _ in note }
                    .eraseToAnyPublisher()
            }
            .withLatestFrom($localData.eraseToAnyPublisher().setFailureType(to: Error.self), resultSelector: {
                ($0, $1)
            })
            .map { note, list -> [NoteModel] in
                var list = list
                list.removeAll(where: { $0.created == note.created })
                return list
            }
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.localData = $0
            })
            .store(in: &cancellations)
        
        //MARK: Add
        let addNotePublisher = input.addNotePublisher
            .flatMap { self.coordinator.goToAddNote() }
            .share()
        
        addNotePublisher
            .withLatestFrom($localData, resultSelector: { ($0, $1) })
            .map { note, list in
                var list = list
                list.append(note)
                return list
            }
            .assign(to: &$localData)
        
        Publishers
            .Merge(
                addNotePublisher.flatMap { self.localUseCase.addNote($0) },
                syncListNoteGeneratorPublisher.flatMap { Publishers.Sequence(sequence: $0.needAddRemote) }
            )
            .flatMap { self.remoteUseCase.addNote($0) }
            .flatMap {
                var note = $0
                note.hasRemote = true
                return self.localUseCase.updateNote(note)
            }
            .withLatestFrom($localData.eraseToAnyPublisher().setFailureType(to: Error.self), resultSelector: { ($0, $1) })
            .map { note, list in
                guard let index = list.firstIndex(where: { $0.created == note.created }) else { return list }
                var note = note
                note.hasRemote = true
                var list = list
                list[index] = note
                return list
            }
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.localData = $0
            })
            .store(in: &cancellations)
    }
    
    func bindSelectAction(input: Input, cancellations: inout Set<AnyCancellable>) {
        let editNotePublisher = input.selectNotePublisher
            .flatMap { self.coordinator.goToEditNote(note: $0) }
            .share()
        
        editNotePublisher
            .withLatestFrom($localData, resultSelector: { ($0, $1) })
            .map { note, list in
                guard let index = list.firstIndex(where: { $0.created == note.created }) else { return list }
                var list = list
                list[index] = note
                return list
            }
            .assign(to: &$localData)
        
        editNotePublisher
            .flatMap {
                Publishers.Zip(self.localUseCase.updateNote($0), self.remoteUseCase.updateNote($0))
            }
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellations)
    }
}
