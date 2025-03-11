//
//  NoteService.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import Foundation
import Combine


enum NoteRouter: APIRouter {
    func path() -> String {
        ""
    }
    
    func method() -> HTTPMethod {
        .post
    }
    
    func params() -> [String : Any] {
        [:]
    }
    
    case addNote(_ data: NoteModel)
    case updateNote(_ data: NoteModel)
    case deleteNote(_ data: NoteModel)
    case getListNote
}
