import UIKit
import Combine
@preconcurrency import CoreData
import Domain

public protocol CoreDataNoteRepository {
    func saveNotes(_ datas: [NoteModel]) -> AnyPublisher<Void, Error>
    func fetchNotes() -> AnyPublisher<[NoteModel], Error>
    func addNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func updateNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
}

public extension Bundle {
    static let coreDataRepositoryBundle = Bundle.module
}

public final class CoreDataNoteRepositoryDefault: CoreDataNoteRepository, @unchecked Sendable {
    public static let shared = CoreDataNoteRepositoryDefault()
        
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: "SernNoteApp", withExtension: ".momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let container = NSPersistentContainer(name: "SernNoteApp", managedObjectModel: model)
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.persistentContainer = container
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    public init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    private var context: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
    
    public func addNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
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
    
    public func updateNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        let context = self.context
        return Future<Void, Error>() { promise in
            context.perform {
                let request = CoreDataNote.fetchRequest()
                request.predicate = NSPredicate(format: "id = %@", data.id as NSNumber)
                request.returnsObjectsAsFaults = false
                do {
                    let listObject = try context.fetch(request)
                    guard let object = listObject.first else {
                        throw GeneralError.localError(msg: "Not found object")
                    }
                    object.updateFromNote(data)
                    try context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        let context = self.context
        return Future<Void, Error>() { promise in
            context.perform {
                let request = CoreDataNote.fetchRequest()
                request.predicate = NSPredicate(format: "id = %@", data.id as NSNumber)
                request.returnsObjectsAsFaults = false
                do {
                    let listObject = try context.fetch(request)
                    guard let object = listObject.first else {
                        throw GeneralError.localError(msg: "Not found object")
                    }
                    context.delete(object)
                    do {
                        try context.save()
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func fetchNotes() -> AnyPublisher<[NoteModel], Error> {
        let context = self.context
        return Future<[NoteModel], Error>() { promise in
            do {
                let coreDataObjects = try context.fetch(CoreDataNote.fetchRequest())
                let ret = coreDataObjects.map { $0.noteModel }
                promise(.success(ret))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func saveNotes(_ datas: [NoteModel]) -> AnyPublisher<Void, Error> {
        let context = self.context
        return Future<Void, Error>() { promise in
            do {
                let batchRequest = NSBatchDeleteRequest(fetchRequest: CoreDataNote.fetchRequest())
                try context.execute(batchRequest)
                datas.forEach { data in
                    let entity = NSEntityDescription.entity(forEntityName: "CoreDataNote", in: context)!
                    let newNote = CoreDataNote(entity: entity, insertInto: context)
                    newNote.updateFromNote(data)
                }
                try context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
