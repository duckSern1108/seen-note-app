//
//  NoteModel.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import Foundation


public struct NoteModel: Hashable, Codable {
    public var hasRemote: Bool = false
    public var isDeleteLocal: Bool = false
    public var title: String = ""
    public var content: String = ""
    public var created: Date = Date()
    public var lastUpdated: Date = Date()
    
    public init() {}
    public init(hasRemote: Bool, isDeleteLocal: Bool, title: String, content: String, created: Date, lastUpdated: Date) {
        self.hasRemote = hasRemote
        self.isDeleteLocal = isDeleteLocal
        self.title = title
        self.content = content
        self.created = created
        self.lastUpdated = lastUpdated
    }
}
