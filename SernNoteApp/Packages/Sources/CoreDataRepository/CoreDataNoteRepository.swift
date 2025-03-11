//
//  CoreDataManageNoteUseCase.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import UIKit
import Combine
import CoreData
import Domain


public protocol CoreDataNoteRepository {
    func saveNotes(_ datas: [NoteModel]) -> AnyPublisher<Void, Error>
    func fetchNotes() -> AnyPublisher<[NoteModel], Error>
    func addNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func updateNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
}

public class CoreDataNoteRepositoryDefault: CoreDataNoteRepository, @unchecked Sendable {
    public static let shared = CoreDataNoteRepositoryDefault()
    
    var context: NSManagedObjectContext!
    var fetchController: NSFetchedResultsController<CoreDataNote>!
    private var persistentContainer: NSPersistentContainer!
    
    private init() {
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: "SernNoteApp", withExtension: ".momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let container = NSPersistentContainer(name: "SernNoteApp", managedObjectModel: model)
        self.persistentContainer = container
        container.loadPersistentStores(completionHandler: { [weak self] (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            guard let self = self else { return }
            self.context = persistentContainer.newBackgroundContext()
            // Create Fetch Request
            let fetchRequest: NSFetchRequest<CoreDataNote> = CoreDataNote.fetchRequest()
            // Configure Fetch Request
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
            self.fetchController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil, cacheName: nil)
        })
        
    }
    
    public func addNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        let context: NSManagedObjectContext! = self.context
        return Future<Void, Error>() { promise in
            let entity = NSEntityDescription.entity(forEntityName: "CoreDataNote", in: context)!
            let newNote = CoreDataNote(entity: entity, insertInto: context)
            newNote.updateFromNote(data)
            do {
                try context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func updateNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        let context: NSManagedObjectContext! = self.context
        return Future<Void, Error>() { promise in
            context.perform { [weak self] in
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
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
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
    
    public func fetchNotes() -> AnyPublisher<[NoteModel], Error> {
        Future<[NoteModel], Error>() { [weak self] promise in
            guard let self = self else {
                promise(.failure(GeneralError.localError(msg: "Không tìm thấy object")))
                return
            }
            do {
                try self.fetchController.performFetch()
                let ret = (self.fetchController.fetchedObjects ?? []).map { $0.noteModel }
                promise(.success(ret))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func saveNotes(_ datas: [NoteModel]) -> AnyPublisher<Void, Error> {
        Future<Void, Error>() { [weak self] promise in
            guard let self = self else {
                promise(.failure(GeneralError.localError(msg: "Không tìm thấy object")))
                return
            }
            do {
                try self.fetchController.performFetch()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
