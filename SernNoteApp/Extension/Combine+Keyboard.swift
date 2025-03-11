//
//  Combine+Keyboard.swift
//  SernNoteApp
//
//  Created by sonnd on 11/3/25.
//

import UIKit
import Combine


struct KeyboardCombine {
    static var heightPublisher: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0 }

        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return Publishers.Merge(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

