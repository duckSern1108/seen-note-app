//
//  SingleNoteVM.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import Foundation
import Combine
import Domain


class SingleNoteVM: BaseViewModel {
    
    struct Input {
        var titlePublisher: AnyPublisher<String, Never>
        var contentPublisher: AnyPublisher<String, Never>
        var backPublisher: AnyPublisher<Void, Never>
    }
    
    struct Output {
        var notePublisher: AnyPublisher<NoteModel, Never>
        var backPublisher: AnyPublisher<Void, Never>
    }
    
    @Published private var title: String = ""
    @Published private var content: String = ""
    @Published private var note: NoteModel = .init()
    
    private let _delegate: PassthroughSubject<NoteModel, Never> = .init()
    var delegate: AnyPublisher<NoteModel, Never> {
        _delegate.eraseToAnyPublisher()
    }
    
    private var cancellations = Set<AnyCancellable>()
    
    init(note: NoteModel) {
        self.note = note
        self.title = note.title
        self.content = note.content
    }
    
    func transform(input: Input) -> Output {
        let backPublisher: AnyPublisher<Void, Never> = input.backPublisher
            .withLatestFrom(Publishers.CombineLatest3(input.titlePublisher, input.contentPublisher, $note), resultSelector: { $1 })
            .filter { (title, content, note) in
                note.title != title || note.content != content
            }
            .map { (title, content, note) in
                var note = note
                note.title = title
                note.content = content
                note.lastUpdated = Date()
                return note
            }
            .handleEvents(receiveOutput: {
                self._delegate.send($0)
            })
            .map { _ in }
            .eraseToAnyPublisher()
        
        return Output(
            notePublisher: $note.eraseToAnyPublisher(),
            backPublisher: backPublisher)
    }
}
