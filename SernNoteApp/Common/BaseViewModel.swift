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
    
    func bind(input: Input, cancellations: inout Set<AnyCancellable>)
}
