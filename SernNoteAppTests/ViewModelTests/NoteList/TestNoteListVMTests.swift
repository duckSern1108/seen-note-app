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
        super.setUp()
        coreDataUseCase = MockCoreDataUseCase()
        remoteUseCase = MockRemoteNoteUseCase()
        coordinator = MockNoteListCoordinator()
        viewModel = .init(
            coreDataUseCase: coreDataUseCase,
            remoteUseCase: remoteUseCase,
            coordinator: coordinator)
    }
    
    func test_transform_sync_publisher_to_call_api() throws {
        let syncListNotePublisher = PassthroughSubject<Void, Never>()
        let output = viewModel.transform(input: .mock(
            syncListNotePublisher: syncListNotePublisher.eraseToAnyPublisher()
        ))
        output.loadPubliser.sink(receiveValue: { _ in }).store(in: &cancellations)
        
        syncListNotePublisher.send(())
        XCTAssertTrue(coreDataUseCase.fetchListNoteCalled)
        XCTAssertTrue(remoteUseCase.getListNoteCalled)
        XCTAssertTrue(coreDataUseCase.saveListNoteCalled)
    }
    
    func test_transform_add_publisher_to_call_api() throws {
        let addNotePublisher = PassthroughSubject<Void, Never>()
        let output = viewModel.transform(input: .mock(
            addNotePublisher: addNotePublisher.eraseToAnyPublisher()
        ))
        output.addNotePublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        addNotePublisher.send(())
        XCTAssertTrue(coreDataUseCase.addNoteCalled)
        XCTAssertTrue(remoteUseCase.addNoteCalled)
        XCTAssertTrue(coreDataUseCase.updateNoteCalled)
    }
    
    func test_transform_edit_publisher_to_call_api() throws {
        let editNotePublisher = PassthroughSubject<NoteModel, Never>()
        let output = viewModel.transform(input: .mock(
            selectNotePublisher: editNotePublisher.eraseToAnyPublisher()
        ))
        output.editNotePublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        editNotePublisher.send(NoteModel())
        XCTAssertTrue(coreDataUseCase.updateNoteCalled)
        XCTAssertTrue(remoteUseCase.updateNoteCalled)
    }
    
    func test_transform_delete_local_note_publisher_to_call_api() throws {
        let deleteNotePublisher = PassthroughSubject<NoteModel, Never>()
        let output = viewModel.transform(input: .mock(
            deleteNotePublisher: deleteNotePublisher.eraseToAnyPublisher()
        ))
        output.deleteNotePublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        deleteNotePublisher.send(NoteModel())
        XCTAssertTrue(coreDataUseCase.deleteNoteCalled)
        XCTAssertFalse(remoteUseCase.deleteNoteCalled)
    }
    
    func test_transform_delete_remote_note_publisher_to_call_api() throws {
        let deleteNotePublisher = PassthroughSubject<NoteModel, Never>()
        let output = viewModel.transform(input: .mock(
            deleteNotePublisher: deleteNotePublisher.eraseToAnyPublisher()
        ))
        output.deleteNotePublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        var remoteNote = NoteModel()
        remoteNote.hasRemote = true
        deleteNotePublisher.send(remoteNote)
        XCTAssertTrue(coreDataUseCase.updateNoteCalled)
        XCTAssertTrue(coreDataUseCase.deleteNoteCalled)
        XCTAssertTrue(remoteUseCase.deleteNoteCalled)
    }
    
    func test_transform_select_publisher_to_navigate_edit_view() {
        let selectNotePublisher = PassthroughSubject<NoteModel, Never>()
        let output = viewModel.transform(input: .mock(
            selectNotePublisher: selectNotePublisher.eraseToAnyPublisher()
        ))
        output.editNotePublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        selectNotePublisher.send(NoteModel())
        XCTAssertTrue(coordinator.didGoToEditNote)
    }
    
    func test_transform_add_publisher_to_navigate_add_view() {
        let addNotePublisher = PassthroughSubject<Void, Never>()
        let output = viewModel.transform(input: .mock(
            addNotePublisher: addNotePublisher.eraseToAnyPublisher()
        ))
        output.addNotePublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        addNotePublisher.send(())
        XCTAssertTrue(coordinator.didGoToAddNote)
    }
    
    func test_transform_search_query_publisher_to_list_note_change() {
        let searchQueryPublisher = PassthroughSubject<String, Never>()
        let output = viewModel.transform(input: .mock(searchQueryPublisher: searchQueryPublisher.eraseToAnyPublisher()))
        var isListNotePublisherSend = false
        output.listNotePubliser
            .sink { _ in
                isListNotePublisherSend = true
            }
            .store(in: &cancellations)
        searchQueryPublisher.send("")
        XCTAssertTrue(isListNotePublisherSend)
    }
}

extension NoteListVM.Input {
    static func mock(
        searchQueryPublisher: AnyPublisher<String, Never> = Just("").eraseToAnyPublisher(),
        syncListNotePublisher: AnyPublisher<Void, Never> = Just(()).eraseToAnyPublisher(),
        addNotePublisher: AnyPublisher<Void, Never> = Just(()).eraseToAnyPublisher(),
        selectNotePublisher: AnyPublisher<NoteModel, Never> = Just(.init()).eraseToAnyPublisher(),
        deleteNotePublisher: AnyPublisher<NoteModel, Never> = Just(.init()).eraseToAnyPublisher()
    ) -> Self {
        .init(
            searchQueryPublisher: searchQueryPublisher,
            syncListNotePublisher: syncListNotePublisher,
            addNotePublisher: addNotePublisher,
            selectNotePublisher: selectNotePublisher,
            deleteNotePublisher: deleteNotePublisher)
    }
}
