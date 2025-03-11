//
//  NoteService.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import Foundation
import Combine
import Domain
import BaseNetwork


public enum NoteRouter: APIRouter {
    public func path() -> String {
        ""
    }
    
    public func method() -> HTTPMethod {
        .post
    }
    
    public func params() -> [String : Any] {
        [:]
    }
    
    public func domain() -> ServerDomain {
        .main
    }
    
    case addNote(_ data: NoteModel)
    case updateNote(_ data: NoteModel)
    case deleteNote(_ data: NoteModel)
    case getListNote
}
