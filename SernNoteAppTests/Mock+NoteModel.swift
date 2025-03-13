//
//  MockNoteModel.swift
//  SernNoteAppTests
//
//  Created by sonnd on 12/3/25.
//

import Foundation
import Domain

extension NoteModel {
    static func mock(hasRemote: Bool = false,
                isDeleteLocal: Bool = false,
                title: String = "",
                content: String = "",
                created: Date = Date(),
                lastUpdated: Date = Date()) -> NoteModel {
        NoteModel(
            hasRemote: hasRemote,
            isDeleteLocal: isDeleteLocal,
            title: title,
            content: content,
            created: created,
            lastUpdated: lastUpdated)
    }
    
    static func mockListNoteInOneMonth(startOfMonth: Date) -> [NoteModel] {
        [
            NoteModel.mock(created: startOfMonth.addingTimeInterval(2)),
            NoteModel.mock(created: startOfMonth.addingTimeInterval(1))
        ]
    }
    
    static var mockListNote: [NoteModel] {
        let date = Date()
        return [
            NoteModel.mock(created: date.addingTimeInterval(3)),
            NoteModel.mock(created: date.addingTimeInterval(2)),
            NoteModel.mock(created: date.addingTimeInterval(1))
        ]
    }
}
