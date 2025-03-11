//
//  NoteModel.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import Foundation


struct NoteModel: Hashable {
    var hasRemote: Bool = false
    var isDeleteLocal: Bool = false
    var title: String = ""
    var content: String = ""
    var created: Date = Date()
    var lastUpdated: Date = Date()
}

extension NoteModel {
    static var mock: [Self] {
        [
            .init(title: "First note", created: Date().addingTimeInterval(-1000)),
            .init(title: "Second note", created: Date().addingTimeInterval(-200)),
        ]
    }
}

extension NoteModel: Codable {
    
}
