//
//  CoreDataNote+CoreDataProperties.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//
//

import Foundation
import CoreData
import Domain


@objc(CoreDataNote)
class CoreDataNote: NSManagedObject {
    
}

extension CoreDataNote {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<CoreDataNote> {
        return NSFetchRequest<CoreDataNote>(entityName: "CoreDataNote")
    }

    @NSManaged var content: String
    @NSManaged var created: Date
    @NSManaged var hasRemote: Bool
    @NSManaged var isDeleteLocal: Bool
    @NSManaged var lastUpdated: Date
    @NSManaged var title: String

}

extension CoreDataNote : Identifiable {
    
}

extension CoreDataNote {
    var noteModel: NoteModel {
        .init(hasRemote: hasRemote,
              isDeleteLocal: isDeleteLocal,
              title: title,
              content: content,
              created: created,
              lastUpdated: lastUpdated)
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
