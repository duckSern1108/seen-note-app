//
//  NoteUIModel.swift
//  SernNoteApp
//
//  Created by sonnd on 13/3/25.
//

import Foundation
import Domain

struct NoteUIModel: Hashable {
    let note: NoteModel
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(note.created)
    }
    
    static func == (lhs: NoteUIModel, rhs: NoteUIModel) -> Bool {
        lhs.note.id == rhs.note.id &&
        lhs.note.title == rhs.note.title &&
        lhs.note.content == rhs.note.content
    }
}
