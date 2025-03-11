//
//  CoreDataManageNoteUseCase.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import UIKit
import Combine
import CoreData


class CoreDataManageNoteUseCase: ManageNoteUseCase {
    let context: NSManagedObjectContext
    let fetchController: NSFetchedResultsController<CoreDataNote>
    
    init(context: NSManagedObjectContext) {
        self.context = context
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<CoreDataNote> = CoreDataNote.fetchRequest()
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        fetchController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                     managedObjectContext: context,
                                                     sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func addNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        
        return Future<NoteModel, Error>() { [weak self] promise in
            guard let self = self else {
                promise(.failure(GeneralError.localError(msg: "Không tìm thấy object")))
                return
            }
            self.context.perform { [weak self] in
                guard let self = self else {
                    promise(.failure(GeneralError.localError(msg: "Không tìm thấy object")))
                    return
                }
                let entity = NSEntityDescription.entity(forEntityName: "CoreDataNote", in: self.context)!
                let newNote = CoreDataNote(entity: entity, insertInto: self.context)
                newNote.updateFromNote(data)
                do {
                    try self.context.save()
                    promise(.success(data))
                } catch {
                    promise(.failure(error))
                }
            }
            
        }
        .eraseToAnyPublisher()
    }
    
    func updateNote(_ data: NoteModel) -> AnyPublisher<NoteModel, Error> {
        Future<NoteModel, Error>() { [weak self] promise in
            guard let self = self else {
                promise(.failure(GeneralError.localError(msg: "Không tìm thấy object")))
                return
            }
            self.context.perform { [weak self] in
                guard let self = self else {
                    promise(.failure(GeneralError.localError(msg: "Không tìm thấy object")))
                    return
                }
                guard let object = self.fetchController.fetchedObjects?.first(where: { $0.created == data.created }) else {
                    promise(.failure(GeneralError.localError(msg: "Không tìm thấy object")))
                    return
                }
                object.updateFromNote(data)
                do {
                    try self.context.save()
                    promise(.success(data))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        Future<Void, Error>() { [weak self] promise in
            guard let self = self else {
                promise(.failure(GeneralError.localError(msg: "Không tìm thấy object")))
                return
            }
            self.context.perform { [weak self] in
                guard let self = self else {
                    promise(.failure(GeneralError.localError(msg: "Không tìm thấy object")))
                    return
                }
                guard let object = self.fetchController.fetchedObjects?.first(where: { $0.created == data.created }) else {
                    promise(.failure(GeneralError.localError(msg: "Không tìm thấy object")))
                    return
                }
                self.context.delete(object)
                do {
                    try self.context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getListNote() -> AnyPublisher<[NoteModel], Error> {
        Future<[NoteModel], Error>() { [weak self] promise in
            guard let self = self else {
                promise(.failure(GeneralError.localError(msg: "Không tìm thấy object")))
                return
            }
            do {
                try self.fetchController.performFetch()
                promise(.success((self.fetchController.fetchedObjects ?? []).map { $0.noteModel }))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
