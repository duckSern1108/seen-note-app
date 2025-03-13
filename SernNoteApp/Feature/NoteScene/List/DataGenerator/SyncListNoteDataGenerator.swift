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

struct SyncListNoteDataGenerator {
    let localData: [NoteModel]
    let remoteData: [NoteModel]
    
    var mergePublisher: AnyPublisher<SyncListNoteModel, Never> {
        let localIdSet: Set<Int> = Set(localData.map { $0.id })
        let remoteIdSet: Set<Int> = Set(remoteData.map { $0.id })
        let unionIdSet = localIdSet.union(remoteIdSet)
        
        let localMap = localData.mapIdToElement
        let remoteMap = remoteData.mapIdToElement
        
        var needAddRemote: [NoteModel] = []
        var needUpdateRemote: [NoteModel] = []
        var needDeleteRemote: [NoteModel] = []
                
        let updatedLocalList: [NoteModel] = unionIdSet.map { id in
            let hasRemote = remoteMap[id] != nil
            let hasLocal = localMap[id] != nil
            switch true {
            case hasRemote && hasLocal:
                var ret: NoteModel
                let isRemoteNewest = remoteMap[id]!.lastUpdated >= localMap[id]!.lastUpdated
                if isRemoteNewest {
                    ret = remoteMap[id]!
                } else {
                    ret = localMap[id]!
                }
                ret.hasRemote = true
                if localMap[id]!.isDeleteLocal {
                    needDeleteRemote.append(remoteMap[id]!)
                } else if !isRemoteNewest {
                    needUpdateRemote.append(ret)
                }
                ret.isDeleteLocal = localMap[id]!.isDeleteLocal
                return ret
                
            case hasRemote:
                var ret = remoteMap[id]!
                ret.hasRemote = true
                return ret
                
            case hasLocal:
                let localData = localMap[id]!
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
    var mapIdToElement: Dictionary<Int, NoteModel> {
        self.reduce([:]) { partialResult, element in
            var partialResult = partialResult
            partialResult[element.id] = element
            return partialResult
        }
    }
}
