import Foundation
import Combine
import Domain


struct NoteUIModel: Hashable {
    let note: NoteModel
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(note.created)
    }
    
    static func == (lhs: NoteUIModel, rhs: NoteUIModel) -> Bool {
        lhs.note.id == rhs.note.id &&
        lhs.note.title == rhs.note.title &&
        lhs.note.content == rhs.note.content
    }
}
struct NoteListVCUIDataGenerator {
    let data: [NoteModel]
    
    var publiser: AnyPublisher<(sections: [Date], map: [Date: [NoteUIModel]]), Never> {
        //Another thread?
        let sorted = data.filter { !$0.isDeleteLocal }.sorted(by: { $0.created > $1.created })
        //Future date
        var currDate: Date? = nil
        var sections: [Date] = []
        let map: [Date: [NoteUIModel]] = sorted.reduce([:]) { partialResult, note in
            if note.created.month != currDate?.month {
                currDate = note.created.startOfMonth()
                sections.append(currDate!)
            }
            guard let currDate = currDate else { return partialResult }
            var partialResult = partialResult
            if partialResult[currDate] == nil {
                partialResult[currDate] = []
            }
            partialResult[currDate]?.append(NoteUIModel(note: note))
            return partialResult
        }
        
        return Just((sections: sections, map: map))
            .eraseToAnyPublisher()
    }
}
