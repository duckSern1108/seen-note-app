//
//  SearchListNoteGeneratorTests.swift
//  SernNoteAppTests
//
//  Created by sonnd on 12/3/25.
//

import XCTest
import Combine
import Domain
@testable import SernNoteApp

final class SearchListNoteGeneratorTests: XCTestCase {
    
    private var cancellations = Set<AnyCancellable>()
    
    func test_generate_data_with_deleted_local_note() {
        let deletedLocalNote = NoteModel.mock(isDeleteLocal: true)
        let normalNote = NoteModel.mock()
        let generator = SearchListNoteGenerator(data: [normalNote, deletedLocalNote], query: "")
        let expect = XCTestExpectation()
        generator.searchPublisher
            .sink(receiveValue: { list in
                XCTAssert(list.count == 1)
                XCTAssertTrue(list[0] == normalNote)
                expect.fulfill()
            })
            .store(in: &cancellations)
        wait(for: [expect])
    }
    
    func test_generate_data_with_deleted_local_note_and_query() {
        let deletedLocalNote = NoteModel.mock(isDeleteLocal: true)
        let mockQuery = "First note"
        let resultNote = NoteModel.mock(title: mockQuery)
        let normalNote = NoteModel.mock()
        let generator = SearchListNoteGenerator(data: [normalNote, deletedLocalNote, resultNote], query: mockQuery)
        let expect = XCTestExpectation()
        generator.searchPublisher
            .sink(receiveValue: { list in
                XCTAssert(list.count == 1)
                XCTAssertTrue(list[0] == resultNote)
                expect.fulfill()
            })
            .store(in: &cancellations)
        wait(for: [expect])
    }
    
    func test_generate_data_with_empty_query() {
        let expect = XCTestExpectation()
        let generator = SearchListNoteGenerator(data: [NoteModel.mock(), NoteModel.mock(), NoteModel.mock()], query: "")
        generator.searchPublisher
            .sink(receiveValue: { list in
                XCTAssert(list.count == 3)
                expect.fulfill()
            })
            .store(in: &cancellations)
        wait(for: [expect])
    }
}
