//
//  GeneralError.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import Foundation


enum GeneralError: Error {
    case unexpected
    case localError(msg: String)
}
