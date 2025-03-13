//
//  SingleNoteVMTests.swift
//  SernNoteAppTests
//
//  Created by sonnd on 12/3/25.
//

import XCTest
import Combine
import Domain
@testable import SernNoteApp

final class SingleNoteVMAddTests: XCTestCase {

    private var viewModel: SingleNoteVM!
    private var note = NoteModel(
        hasRemote: false,
        isDeleteLocal: false,
        title: "First note",
        content: "Second note",
        created: Date(),
        lastUpdated: Date())
    private var cancellations = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        viewModel = SingleNoteVM(note: NoteModel())
    }
    
    func test_note_call_delegate_when_back_with_empty_data() throws {
        let backPublisher = PassthroughSubject<Void, Never>()
        let output = viewModel.transform(input: .init(
            titlePublisher: Just("").eraseToAnyPublisher(),
            contentPublisher: Just("").eraseToAnyPublisher(),
            backPublisher: backPublisher.eraseToAnyPublisher()))
        output.backPublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        var delegateNote: NoteModel?
        viewModel.delegate
            .sink(receiveValue: {
            delegateNote = $0
        })
        .store(in: &cancellations)
        backPublisher.send(())
        XCTAssertNil(delegateNote)
    }
    
    func test_note_call_delegate_when_back_with_empty_title() throws {
        let backPublisher = PassthroughSubject<Void, Never>()
        let mockContent = "Content"
        let output = viewModel.transform(input: .init(
            titlePublisher: Just("").eraseToAnyPublisher(),
            contentPublisher: Just(mockContent).eraseToAnyPublisher(),
            backPublisher: backPublisher.eraseToAnyPublisher()))
        output.backPublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        var delegateNote: NoteModel?
        viewModel.delegate
            .sink(receiveValue: {
            delegateNote = $0
        })
        .store(in: &cancellations)
        backPublisher.send(())
        XCTAssertNotNil(delegateNote)
        XCTAssertTrue(delegateNote?.title == "")
        XCTAssertTrue(delegateNote?.content == mockContent)
    }
    
    func test_note_call_delegate_when_back_with_empty_content() throws {
        let backPublisher = PassthroughSubject<Void, Never>()
        let mockTitle = "Title"
        let output = viewModel.transform(input: .init(
            titlePublisher: Just(mockTitle).eraseToAnyPublisher(),
            contentPublisher: Just("").eraseToAnyPublisher(),
            backPublisher: backPublisher.eraseToAnyPublisher()))
        output.backPublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        var delegateNote: NoteModel?
        viewModel.delegate
            .sink(receiveValue: {
            delegateNote = $0
        })
        .store(in: &cancellations)
        backPublisher.send(())
        XCTAssertNotNil(delegateNote)
        XCTAssertTrue(delegateNote?.title == mockTitle)
        XCTAssertTrue(delegateNote?.content == "")
    }
    
    func test_note_call_delegate_when_back_with_full_data() throws {
        let backPublisher = PassthroughSubject<Void, Never>()
        let mockTitle = "Title"
        let mockContent = "Content"
        let output = viewModel.transform(input: .init(
            titlePublisher: Just(mockTitle).eraseToAnyPublisher(),
            contentPublisher: Just(mockContent).eraseToAnyPublisher(),
            backPublisher: backPublisher.eraseToAnyPublisher()))
        output.backPublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        var delegateNote: NoteModel?
        viewModel.delegate
            .sink(receiveValue: {
            delegateNote = $0
        })
        .store(in: &cancellations)
        backPublisher.send(())
        XCTAssertNotNil(delegateNote)
        XCTAssertTrue(delegateNote?.title == mockTitle)
        XCTAssertTrue(delegateNote?.content == mockContent)
    }
}
