import Foundation
import Domain
import BaseNetwork

public enum NoteRouter: APIRouter {
    
    case addNote(_ data: NoteModel)
    case updateNote(_ data: NoteModel)
    case deleteNote(_ data: NoteModel)
    case getListNote
    
    public func path() -> String {
        switch self {
        case .addNote:
            return "/items"
        case .updateNote:
            return "/items"
        case .deleteNote(let note):
            return "/items/\(note.id)"
        case .getListNote:
            return "/items"
        }
    }
    
    public func method() -> HTTPMethod {
        switch self {
        case .addNote:
            return .put
        case .updateNote:
            return .put
        case .deleteNote:
            return .delete
        case .getListNote:
            return .get
        }
    }
    
    public func params() -> [String : Any] {
        switch self {
        case .addNote(let note):
            return note.apiDict
        case .updateNote(let note):
            return note.apiDict
        case .deleteNote:
            return [:]
        case .getListNote:
            return [:]
        }
    }
    
    public func domain() -> ServerDomain {
        .aws
    }
}

private extension NoteModel {
    var apiDict: [String: Any] {
        [
            "id": id,
            "title": title,
            "content": content,
            "created": created.timeIntervalSince1970,
            "lastUpdated": lastUpdated.timeIntervalSince1970
        ]
    }
}
