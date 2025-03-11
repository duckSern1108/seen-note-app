//
//  CoreDataManageNoteUseCase.swift
//  SernNoteApp
//
//  Created by sonnd on 7/3/25.
//

import UIKit
import Combine
import CoreData


protocol CoreDataManageNoteUseCase {
    var notes: AnyPublisher<[NoteModel], Never> { get }
    
    func addNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func updateNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func fetchNotes() -> AnyPublisher<Void, Error>
    func saveNotes(_ datas: [NoteModel]) -> AnyPublisher<Void, Error>
}

protocol CoreDataManageNoteRepository {
    func saveNotes(_ datas: [NoteModel]) -> AnyPublisher<Void, Error>
    func fetchNotes() -> AnyPublisher<[NoteModel], Error>
    func addNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func updateNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
}

class CoreDataManageNoteUseCaseDefault: CoreDataManageNoteUseCase {
    private let _notes = CurrentValueSubject<[NoteModel], Never>([])
    
    var notes: AnyPublisher<[NoteModel], Never> { _notes.eraseToAnyPublisher() }
    
    private let repository: CoreDataManageNoteRepository
    
    init(repository: CoreDataManageNoteRepository) {
        self.repository = repository
    }
    
    func addNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        repository.addNote(data)
            .flatMap { self.fetchNotes() }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    func updateNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        repository.updateNote(data)
            .flatMap { self.fetchNotes() }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        repository.deleteNote(data)
            .flatMap { self.fetchNotes() }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    func fetchNotes() -> AnyPublisher<Void, Error> {
        repository.fetchNotes()
            .handleEvents(receiveOutput: { [weak self] in
                guard let self = self else { return }
                self._notes.value = $0
            })
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    func saveNotes(_ datas: [NoteModel]) -> AnyPublisher<Void, any Error> {
        repository.saveNotes(datas)
    }
}

class CoreDataManageNoteRepositoryDefault: CoreDataManageNoteRepository {
    
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
    
    func addNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        let context = self.context
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
    
    func updateNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        let context = self.context
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
    
    func fetchNotes() -> AnyPublisher<[NoteModel], Error> {
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
    
    func saveNotes(_ datas: [NoteModel]) -> AnyPublisher<Void, Error> {
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
