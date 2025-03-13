//
//  NoteListVCUIDataGeneratorTests.swift
//  SernNoteAppTests
//
//  Created by sonnd on 12/3/25.
//

import XCTest
import Combine
import Domain
@testable import SernNoteApp

final class NoteListVCUIDataGeneratorTests: XCTestCase {
    
    private var cancellations = Set<AnyCancellable>()
    
    func test_generate_note_in_one_month_to_one_section() throws {
        let startOfMonth = Date().startOfMonth()
        
        let firstNote = NoteModel.mock(created: startOfMonth.addingTimeInterval(1))
        let secondNote = NoteModel.mock(created: startOfMonth.addingTimeInterval(2))
        let listNote = NoteModel.mockListNoteInOneMonth(startOfMonth: startOfMonth)
        let listNoteUI = listNote.map { NoteUIModel(note: $0) }
        let generator = NoteListVCUIDataGenerator(data: listNote)
        let expect = XCTestExpectation()
        generator.publiser
            .sink(receiveValue: { (sections, map) in
                XCTAssert(sections.count == 1)
                XCTAssert(sections[0] == startOfMonth)
                XCTAssert(map.keys.count == 1)
                XCTAssert(map[startOfMonth] == listNoteUI)
                expect.fulfill()
            })
            .store(in: &cancellations)
        wait(for: [expect])
    }
    
    func test_generate_note_in_two_month_to_two_section() throws {
        let expect = XCTestExpectation()
        let firstStartOfMonth = Date.mockDateFrom(month: 1, year: 2001).startOfMonth()
        let secondStartOfMonth = Date.mockDateFrom(month: 2, year: 2001).startOfMonth()
        
        let firstMonthListNotes = NoteModel.mockListNoteInOneMonth(startOfMonth: firstStartOfMonth)
        let firstMothListNotesUI = firstMonthListNotes.map { NoteUIModel(note: $0) }
        let secondMonthListNotes = NoteModel.mockListNoteInOneMonth(startOfMonth: secondStartOfMonth)
        let secondMonthListNotesUI = secondMonthListNotes.map { NoteUIModel(note: $0) }
        let generator = NoteListVCUIDataGenerator(data: (firstMonthListNotes + secondMonthListNotes).shuffled())
        generator.publiser
            .sink(receiveValue: { (sections, map) in
                XCTAssert(sections.count == 2)
                XCTAssert(sections == [secondStartOfMonth, firstStartOfMonth])
                XCTAssert(map.keys.count == 2)
                XCTAssert(map[firstStartOfMonth] == firstMothListNotesUI)
                XCTAssert(map[secondStartOfMonth] == secondMonthListNotesUI)
                expect.fulfill()
            })
            .store(in: &cancellations)
        wait(for: [expect])
    }
}
