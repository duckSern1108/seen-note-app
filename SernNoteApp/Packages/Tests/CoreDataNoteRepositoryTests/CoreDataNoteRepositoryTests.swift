//
//  CoreDataNoteRepositoryTests.swift
//  Packages
//
//  Created by sonnd on 12/3/25.
//

import XCTest
import Combine
@preconcurrency import CoreData
import Domain
import CoreDataRepository


final class CoreDataNoteRepositoryTests: XCTestCase {
    
    private var repository: CoreDataNoteRepositoryDefault!
    private var persistentContainer: NSPersistentContainer!
    private var cancellations = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle.coreDataRepositoryBundle
        let modelURL = bundle.url(forResource: "SernNoteApp", withExtension: ".momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        
        let container = NSPersistentContainer(name: "SernNoteApp", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.persistentContainer = container
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        repository = CoreDataNoteRepositoryDefault(persistentContainer: persistentContainer)
    }
    
    
    func test_save_notes() throws {
        let expect = XCTestExpectation()
        let newNotes = CoreDataNoteRepositoryTests.mockListNote
        repository.saveNotes(newNotes)
            .flatMap { [unowned self] in
                self.repository.fetchNotes()
            }
            .sink(receiveCompletion: { ret in
                switch ret {
                case .finished:
                    break
                case .failure(let failure):
                    XCTAssertThrowsError(failure)
                }
                expect.fulfill()
            }, receiveValue: {
                XCTAssert(Set(newNotes) == Set($0))
                expect.fulfill()
            })
            .store(in: &cancellations)
        wait(for: [expect])
    }
    
    func test_add_notes() throws {
        let expect = XCTestExpectation()
        let newData = NoteModel()
        repository.fetchNotes()
            .flatMap { [unowned self] currentList -> AnyPublisher<Int, Error> in
                self.repository.addNote(newData)
                    .map { currentList.count }
                    .eraseToAnyPublisher()
            }
            .flatMap { [unowned self] oldCount -> AnyPublisher<(oldCount: Int, newList: [NoteModel]), Error> in
                self.repository.fetchNotes()
                    .map {
                        (oldCount: oldCount, newList: $0)
                    }
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { ret in
                switch ret {
                case .finished:
                    break
                case .failure(let failure):
                    XCTAssertThrowsError(failure)
                }
                expect.fulfill()
            }, receiveValue: { (oldCount, newList) in
                XCTAssertTrue(newList.count - oldCount == 1)
                XCTAssertTrue(newList.contains(newData))
                expect.fulfill()
            })
            .store(in: &cancellations)
        wait(for: [expect])
    }
    
    func test_delete_notes() throws {
        let note = NoteModel()
        let expect = XCTestExpectation()
        repository.fetchNotes()
            .flatMap { [unowned self] currentList -> AnyPublisher<Int, Error> in
                self.repository.addNote(note)
                    .map { currentList.count }
                    .eraseToAnyPublisher()
            }
            .flatMap { [unowned self] oldCount -> AnyPublisher<Int, Error> in
                self.repository.deleteNote(note)
                    .map { oldCount }
                    .eraseToAnyPublisher()
            }
            .flatMap { [unowned self] oldCount -> AnyPublisher<(oldCount: Int, newList: [NoteModel]), Error> in
                self.repository.fetchNotes()
                    .map {
                        (oldCount: oldCount, newList: $0)
                    }
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { ret in
                switch ret {
                case .finished:
                    break
                case .failure(let failure):
                    XCTAssertThrowsError(failure)
                }
                expect.fulfill()
            },
                  receiveValue: { (oldCount, newList) in
                XCTAssertFalse(newList.contains(note))
                XCTAssertTrue(oldCount == newList.count)
                expect.fulfill()
            })
            .store(in: &cancellations)
        wait(for: [expect])
    }
    
    func test_update_notes() throws {
        let note = NoteModel()
        var updatedNote = note
        let mockTitle = "Title"
        updatedNote.title = mockTitle
        let expect = XCTestExpectation()
        repository.fetchNotes()
            .flatMap { [unowned self] currentList -> AnyPublisher<Int, Error> in
                self.repository.addNote(note)
                    .map { currentList.count }
                    .eraseToAnyPublisher()
            }
            .flatMap { [unowned self] oldCount -> AnyPublisher<Int, Error> in
                self.repository.updateNote(updatedNote)
                    .map { oldCount }
                    .eraseToAnyPublisher()
            }
            .flatMap { [unowned self] oldCount -> AnyPublisher<(oldCount: Int, newList: [NoteModel]), Error> in
                self.repository.fetchNotes()
                    .map { (oldCount: oldCount, newList: $0) }
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { ret in
                switch ret {
                case .finished:
                    break
                case .failure(let failure):
                    XCTAssertThrowsError(failure)
                }
                expect.fulfill()
            }, receiveValue: { (oldCount, newList) in
                XCTAssertTrue(newList.contains(where: { $0 == updatedNote }))
                XCTAssertFalse(newList.contains(where: { $0 == note }))
                expect.fulfill()
            })
            .store(in: &cancellations)
        wait(for: [expect])
    }
}

private extension CoreDataNoteRepositoryTests {
    static var mockListNote: [NoteModel] {
        [
            .init(hasRemote: false, isDeleteLocal: true, title: "First note", content: "Content", created: Date().addingTimeInterval(-100), lastUpdated: Date()),
            .init(hasRemote: false, isDeleteLocal: true, title: "Second note", content: "Content", created: Date().addingTimeInterval(-99), lastUpdated: Date()),
            .init(hasRemote: false, isDeleteLocal: true, title: "Third note", content: "Content", created: Date().addingTimeInterval(-66), lastUpdated: Date())
        ]
    }
}
