import Foundation
import Combine
import Domain

struct SearchListNoteGenerator {
    let data: [NoteModel]
    let query: String
    
    var searchPublisher: AnyPublisher<[NoteModel], Never> {
        let normalizeQuery = query.lowercased()
        return Just(
            data.filter {
                guard !$0.isDeleteLocal else { return false }
                guard !query.isEmpty else { return true }
                return $0.title.lowercased().contains(normalizeQuery) || $0.content.lowercased().contains(normalizeQuery)
            }
                .sorted(by: { $0.created > $1.created })
        )
        .eraseToAnyPublisher()
    }
}
