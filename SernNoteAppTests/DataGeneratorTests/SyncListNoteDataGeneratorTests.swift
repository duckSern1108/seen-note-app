//
//  SyncListNoteDataGeneratorTests.swift
//  SernNoteAppTests
//
//  Created by sonnd on 12/3/25.
//

import XCTest
import Combine
import Domain
@testable import SernNoteApp


final class SyncListNoteDataGeneratorTests: XCTestCase {
    
    private var cancellations = Set<AnyCancellable>()
    
    func test_generate_result_with_new_remote_data() throws {
        let remoteData = NoteModel.mockListNote
        
        let generator = SyncListNoteDataGenerator(localData: [], remoteData: remoteData)
        generator.mergePublisher
            .sink(receiveValue: { result in
                XCTAssert(result.updatedLocalList.count == remoteData.count)
            })
            .store(in: &cancellations)
    }
    
    func test_generate_result_with_new_local_note() throws {
        let localData = NoteModel.mockListNote
        let generator = SyncListNoteDataGenerator(localData: localData, remoteData: [])
        generator.mergePublisher
            .sink(receiveValue: { result in
                XCTAssert(result.updatedLocalList.count == localData.count)
                XCTAssert(result.needAddRemote.count == localData.count)
            })
            .store(in: &cancellations)
    }
    
    func test_generate_result_with_data_both_in_local_and_remote_with_local_newest() throws {
        let createDate = Date().startOfDay()
        let localNote = NoteModel.mock(created: createDate, lastUpdated: createDate.addingTimeInterval(2))
        let remoteNote = NoteModel.mock(created: createDate, lastUpdated: createDate.addingTimeInterval(1))
        let generator = SyncListNoteDataGenerator(localData: [localNote], remoteData: [remoteNote])
        generator.mergePublisher
            .sink(receiveValue: { result in
                XCTAssert(result.updatedLocalList.count == 1)
                XCTAssert(result.needUpdateRemote.count == 1)
                //XCTAssert(result.needUpdateRemote[0].lastUpdated == localNote.lastUpdated)
            })
            .store(in: &cancellations)
    }
    
    func test_generate_result_with_data_both_in_local_and_remote_with_remote_newest() throws {
        let createDate = Date().startOfDay()
        let localNote = NoteModel.mock(created: createDate, lastUpdated: createDate.addingTimeInterval(1))
        let remoteNote = NoteModel.mock(created: createDate, lastUpdated: createDate.addingTimeInterval(2))
        let generator = SyncListNoteDataGenerator(localData: [localNote], remoteData: [remoteNote])
        generator.mergePublisher
            .sink(receiveValue: { result in
                XCTAssert(result.updatedLocalList.count == 1)
                XCTAssert(result.needUpdateRemote.isEmpty)
            })
            .store(in: &cancellations)
    }
    
    func test_generate_with_data_delete_local_but_not_in_remote() throws {
        let isDeleteLocalNote = NoteModel.mock(isDeleteLocal: true)
        let remoteNoteOfIsDeleteLocalNote = isDeleteLocalNote
        let generator = SyncListNoteDataGenerator(localData: [isDeleteLocalNote], remoteData: [remoteNoteOfIsDeleteLocalNote])
        generator.mergePublisher
            .sink(receiveValue: { result in
                XCTAssert(result.updatedLocalList.count == 1)
                XCTAssert(result.needDeleteRemote.count == 1)
            })
            .store(in: &cancellations)
    }
    
    func test_generate_with_new_data_both_from_remote_and_local() throws {
        let createDate = Date().startOfDay()
        let localNote = NoteModel.mock(hasRemote: false, created: createDate)
        let remoteNote = NoteModel.mock(created: createDate.addingTimeInterval(1))
        let generator = SyncListNoteDataGenerator(localData: [localNote], remoteData: [remoteNote])
        generator.mergePublisher
            .sink(receiveValue: { result in
                XCTAssert(result.updatedLocalList.count == 2)
            })
            .store(in: &cancellations)
    }
}
