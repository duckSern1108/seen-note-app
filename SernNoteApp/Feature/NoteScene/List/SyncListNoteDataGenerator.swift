//
//  SyncListNoteDataGenerator.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import Foundation
import Combine
import Domain


struct SyncListNoteModel {
    var updatedLocalList: [NoteModel]
    
    var needAddRemote: [NoteModel]
    var needUpdateRemote: [NoteModel]
    var needDeleteRemote: [NoteModel]
}

//TODO: Unit test
struct SyncListNoteDataGenerator {
    let localData: [NoteModel]
    let remoteData: [NoteModel]
    
    var mergePublisher: AnyPublisher<SyncListNoteModel, Never> {
        let localCreateDateSet: Set<Date> = Set(localData.map { $0.created })
        let remoteCreateDateSet: Set<Date> = Set(remoteData.map { $0.created })
        let unionCreateDateSet = localCreateDateSet.union(remoteCreateDateSet)
        
        let localMap = localData.mapCreateDateToElement
        let remoteMap = remoteData.mapCreateDateToElement
        
        var needAddRemote: [NoteModel] = []
        var needUpdateRemote: [NoteModel] = []
        var needDeleteRemote: [NoteModel] = []
                
        let updatedLocalList: [NoteModel] = unionCreateDateSet.map { date in
            let hasRemote = remoteMap[date] != nil
            let hasLocal = localMap[date] != nil
            switch true {
            case hasRemote && hasLocal:
                var ret: NoteModel
                let isRemoteNewest = remoteMap[date]!.lastUpdated > localMap[date]!.lastUpdated
                if isRemoteNewest {
                    ret = remoteMap[date]!
                } else {
                    ret = localMap[date]!
                }
                ret.hasRemote = true
                if localMap[date]!.isDeleteLocal {
                    needDeleteRemote.append(remoteMap[date]!)
                } else if !isRemoteNewest {
                    needUpdateRemote.append(ret)
                }
                ret.isDeleteLocal = localMap[date]!.isDeleteLocal
                return ret
                
            case hasRemote:
                var ret = remoteMap[date]!
                ret.hasRemote = true
                return ret
                
            case hasLocal:
                let localData = localMap[date]!
                if !localData.hasRemote {
                    needAddRemote.append(localData)
                }
                return localData
            default:
                return .init()
            }
        }
        return Just(.init(
            updatedLocalList: updatedLocalList,
            needAddRemote: needAddRemote,
            needUpdateRemote: needUpdateRemote,
            needDeleteRemote: needDeleteRemote))
        .eraseToAnyPublisher()
    }
}

private extension Array where Element == NoteModel {
    var mapCreateDateToElement: Dictionary<Date, NoteModel> {
        self.reduce([:]) { partialResult, element in
            var partialResult = partialResult
            partialResult[element.created] = element
            return partialResult
        }
    }
}
