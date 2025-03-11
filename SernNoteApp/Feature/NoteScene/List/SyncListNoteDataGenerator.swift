//
//  SyncListNoteDataGenerator.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import Foundation
import Combine


struct SyncListNoteModel {
    var syncList: [NoteModel]
    var needAddLocal: [NoteModel]
    var needUpdateLocal: [NoteModel]
    var needDeleteLocal: [NoteModel]
    
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
        
        var needAddLocal: [NoteModel] = []
        var needUpdateLocal: [NoteModel] = []
        var needDeleteLocal: [NoteModel] = []
        var needAddRemote: [NoteModel] = []
        var needUpdateRemote: [NoteModel] = []
        var needDeleteRemote: [NoteModel] = []
        
        
        let syncList: [NoteModel] = unionCreateDateSet.map { date in
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
                    needDeleteRemote.append(ret)
                } else if isRemoteNewest {
                    needUpdateLocal.append(ret)
                } else {
                    needUpdateRemote.append(ret)
                }
                ret.isDeleteLocal = localMap[date]!.isDeleteLocal
                return ret
                
            case hasRemote:
                var ret = remoteMap[date]!
                ret.hasRemote = true
                needAddLocal.append(ret)
                return ret
                
            case hasLocal:
                let localData = localMap[date]!
                if localData.hasRemote {
                    if localData.isDeleteLocal {
                        needDeleteLocal.append(localData)
                    }
                } else {
                    needAddRemote.append(localData)
                }
                return localData
            default:
                return .init()
            }
        }
        return Just(.init(
            syncList: syncList,
            needAddLocal: needAddLocal,
            needUpdateLocal: needUpdateLocal,
            needDeleteLocal: needDeleteLocal,
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
