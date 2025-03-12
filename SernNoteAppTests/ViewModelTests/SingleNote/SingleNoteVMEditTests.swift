//
//  SingleNoteVMEditTests.swift
//  SernNoteAppTests
//
//  Created by sonnd on 12/3/25.
//

import Foundation


import XCTest
import Combine
import Domain
@testable import SernNoteApp



final class SingleNoteVMEditTests: XCTestCase {

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
        viewModel = SingleNoteVM(note: note)
    }
    
    func test_note_call_delegate_when_back_with_same_data_before() throws {
        let backPublisher = PassthroughSubject<Void, Never>()
        let output = viewModel.transform(input: .init(
            titlePublisher: Just(note.title).eraseToAnyPublisher(),
            contentPublisher: Just(note.content).eraseToAnyPublisher(),
            backPublisher: backPublisher.eraseToAnyPublisher()))
        output.backPublisher.sink(receiveValue: { _ in }).store(in: &cancellations)
        var delegateNote: NoteModel?
        viewModel.delegate
            .sink(receiveValue: {
            delegateNote = $0
        })
        .store(in: &cancellations)
        backPublisher.send(())
        XCTAssertNil(delegateNote == nil)
    }
    
    func test_note_call_delegate_when_back_with_different_data_before() throws {
        let backPublisher = PassthroughSubject<Void, Never>()
        let mockTitle = note.title + "\n"
        let mockContent = note.content + "\n"
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
