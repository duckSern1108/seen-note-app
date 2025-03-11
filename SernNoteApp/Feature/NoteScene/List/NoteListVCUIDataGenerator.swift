import Foundation
import Combine
import Domain


struct NoteListVCUIDataGenerator {
    let data: [NoteModel]
    
    var publiser: AnyPublisher<(sections: [Date], map: [Date: [NoteModel]]), Never> {
        //Another thread?
        let sorted = data.filter { !$0.isDeleteLocal }.sorted(by: { $0.created > $1.created })
        //Future date
        var currDate: Date? = nil
        var sections: [Date] = []
        let map: [Date: [NoteModel]] = sorted.reduce([:]) { partialResult, note in
            if note.created.month != currDate?.month {
                currDate = note.created.startOfMonth()
                sections.append(currDate!)
            }
            guard let currDate = currDate else { return partialResult }
            var partialResult = partialResult
            if partialResult[currDate] == nil {
                partialResult[currDate] = []
            }
            partialResult[currDate]?.append(note)
            return partialResult
        }
        
        return Just((sections: sections, map: map))
            .eraseToAnyPublisher()
    }
}
