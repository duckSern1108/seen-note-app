//
//  SingleNoteVM.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import Foundation
import Combine


class SingleNoteVM: BaseViewModel {
    
    struct Input {
        var titlePublisher: AnyPublisher<String, Never>
        var contentPublisher: AnyPublisher<String, Never>
        var backPublisher: AnyPublisher<Void, Never>
        var donePublisher: AnyPublisher<Void, Never>
    }
    
    @Published private(set) var title: String = ""
    @Published private(set) var content: String = ""
    @Published private(set) var note: NoteModel = .init()
    
    let delegate: PassthroughSubject<NoteModel, Never> = .init()
    
    private var cancellations = Set<AnyCancellable>()
    
    init(note: NoteModel) {
        self.note = note
        self.title = note.title
        self.content = note.content
    }
    
    func bind(input: Input, cancellations: inout Set<AnyCancellable>) {
        input.titlePublisher.share()
            .assign(to: &$title)
        
        input.contentPublisher.share()
            .assign(to: &$content)
        
        input.backPublisher
            .withLatestFrom(Publishers.CombineLatest3($title, $content, $note), resultSelector: { $1 })
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
            .sink { [weak self] in
                self?.delegate.send($0)
            }
            .store(in: &cancellations)
    }
}
