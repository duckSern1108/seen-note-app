//
//  BaseViewModel.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import Foundation
import Combine

protocol BaseViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
