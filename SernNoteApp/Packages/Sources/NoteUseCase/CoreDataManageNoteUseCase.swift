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
import CoreDataRepository


public protocol CoreDataNoteUseCase {
    var notes: AnyPublisher<[NoteModel], Never> { get }
    
    func addNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func updateNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error>
    func fetchNotes() -> AnyPublisher<Void, Error>
    func saveNotes(_ datas: [NoteModel]) -> AnyPublisher<Void, Error>
}

public class CoreDataNoteUseCaseDefault: CoreDataNoteUseCase {
    private let _notes = CurrentValueSubject<[NoteModel], Never>([])
    
    public var notes: AnyPublisher<[NoteModel], Never> { _notes.eraseToAnyPublisher() }
    
    private let repository: CoreDataNoteRepository
    
    public init(repository: CoreDataNoteRepository) {
        self.repository = repository
    }
    
    public func addNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        repository.addNote(data)
            .flatMap { self.fetchNotes() }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    public func updateNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        repository.updateNote(data)
            .flatMap { self.fetchNotes() }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    public func deleteNote(_ data: NoteModel) -> AnyPublisher<Void, Error> {
        repository.deleteNote(data)
            .flatMap { self.fetchNotes() }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    public func fetchNotes() -> AnyPublisher<Void, Error> {
        repository.fetchNotes()
            .handleEvents(receiveOutput: { [weak self] in
                guard let self = self else { return }
                self._notes.value = $0
            })
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    public func saveNotes(_ datas: [NoteModel]) -> AnyPublisher<Void, any Error> {
        repository.saveNotes(datas)
    }
}
