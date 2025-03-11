//
//  CoreDataNote+CoreDataProperties.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//
//

import Foundation
import CoreData


extension CoreDataNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataNote> {
        return NSFetchRequest<CoreDataNote>(entityName: "CoreDataNote")
    }

    @NSManaged public var content: String
    @NSManaged public var created: Date
    @NSManaged public var hasRemote: Bool
    @NSManaged public var isDeleteLocal: Bool
    @NSManaged public var lastUpdated: Date
    @NSManaged public var title: String

}

extension CoreDataNote : Identifiable {

}

extension CoreDataNote {
    var noteModel: NoteModel {
        .init(hasRemote: hasRemote, isDeleteLocal: isDeleteLocal, title: title, content: content, created: created, lastUpdated: lastUpdated)
    }
    
    func updateFromNote(_ data: NoteModel) {
        title = data.title
        content = data.content
        created = data.created
        lastUpdated = data.lastUpdated
        isDeleteLocal = data.isDeleteLocal
        hasRemote = data.hasRemote
    }
}
