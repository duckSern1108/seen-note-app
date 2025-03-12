//
//  TestNoteListVM.swift
//  SernNoteAppTests
//
//  Created by sonnd on 12/3/25.
//

import XCTest
import Combine
@testable import SernNoteApp
import NoteUseCase
import Domain


final class TestNoteListVMTests: XCTestCase {
    
    private var viewModel: NoteListVM!
    private var coreDataUseCase: MockCoreDataUseCase!
    private var remoteUseCase: MockRemoteNoteUseCase!
    private var coordinator: MockNoteListCoordinator!
    private var cancellations = Set<AnyCancellable>()
    
    override func setUp() {
        coreDataUseCase = MockCoreDataUseCase()
        remoteUseCase = MockRemoteNoteUseCase()
        coordinator = MockNoteListCoordinator()
        viewModel = .init(
            coreDataUseCase: coreDataUseCase,
            remoteUseCase: remoteUseCase,
            coordinator: coordinator)
    }
    
    func test_sync_local_list_when_trigger() throws {
        let syncListNotePublisher = PassthroughSubject<Void, Never>()
        let output = viewModel.transform(input: .mock(
            syncListNotePublisher: syncListNotePublisher.eraseToAnyPublisher()
        ))
        output.loadPubliser.sink(receiveValue: { _ in }).store(in: &cancellations)
        
        syncListNotePublisher.send(())
        XCTAssertTrue(coreDataUseCase.fetchListNoteCalled, "Not call get data from core data")
        XCTAssertTrue(coreDataUseCase.saveListNoteCalled, "Not call save data to core data")
        XCTAssertTrue(remoteUseCase.getListNoteCalled, "Not call get data from remote")
    }
    
    func test_call_api_when_add() throws {
        let addNotePublisher = PassthroughSubject<Void, Never>()
        let output = viewModel.transform(input: .mock(
            addNotePublisher: addNotePublisher.eraseToAnyPublisher()
        ))
        output.addNotePublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        addNotePublisher.send(())
        XCTAssertTrue(coreDataUseCase.addNoteCalled, "Not call add to core data")
        XCTAssertTrue(remoteUseCase.addNoteCalled, "Note call add data to remote")
    }
    
    func test_call_api_when_edit() throws {
        let editNotePublisher = PassthroughSubject<NoteModel, Never>()
        let output = viewModel.transform(input: .mock(
            selectNotePublisher: editNotePublisher.eraseToAnyPublisher()
        ))
        output.editNotePublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        editNotePublisher.send(NoteModel())
        XCTAssertTrue(coreDataUseCase.updateNoteCalled, "Not call update to core data")
        XCTAssertTrue(remoteUseCase.updateNoteCalled, "Note call update data to remote")
    }
    
    func test_call_api_when_delete_local_note() throws {
        let deleteNotePublisher = PassthroughSubject<NoteModel, Never>()
        let output = viewModel.transform(input: .mock(
            deleteNotePublisher: deleteNotePublisher.eraseToAnyPublisher()
        ))
        output.deleteNotePublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        deleteNotePublisher.send(NoteModel())
        XCTAssertTrue(coreDataUseCase.deleteNoteCalled, "Not call delete to core data")
        XCTAssertTrue(!remoteUseCase.deleteNoteCalled, "Note call delete data to remote")
    }
    
    func test_call_api_when_delete_remote_note() throws {
        let deleteNotePublisher = PassthroughSubject<NoteModel, Never>()
        let output = viewModel.transform(input: .mock(
            deleteNotePublisher: deleteNotePublisher.eraseToAnyPublisher()
        ))
        output.deleteNotePublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        var remoteNote = NoteModel()
        remoteNote.hasRemote = true
        deleteNotePublisher.send(remoteNote)
        XCTAssertTrue(coreDataUseCase.updateNoteCalled, "Not call update to core data")
        XCTAssertTrue(coreDataUseCase.deleteNoteCalled, "Not call delete to core data")
        XCTAssertTrue(remoteUseCase.deleteNoteCalled, "Note call delete data to remote")
    }
}

extension NoteListVM.Input {
    static func mock(
        searchQuery: AnyPublisher<String, Never> = Just("").eraseToAnyPublisher(),
        syncListNotePublisher: AnyPublisher<Void, Never> = Just(()).eraseToAnyPublisher(),
        addNotePublisher: AnyPublisher<Void, Never> = Just(()).eraseToAnyPublisher(),
        selectNotePublisher: AnyPublisher<NoteModel, Never> = Just(.init()).eraseToAnyPublisher(),
        deleteNotePublisher: AnyPublisher<NoteModel, Never> = Just(.init()).eraseToAnyPublisher()
    ) -> Self {
        .init(
            searchQuery: searchQuery,
            syncListNotePublisher: syncListNotePublisher,
            addNotePublisher: addNotePublisher,
            selectNotePublisher: selectNotePublisher,
            deleteNotePublisher: deleteNotePublisher)
    }
}
