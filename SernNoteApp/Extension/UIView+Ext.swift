//
//  UIView+Ext.swift
//  SernNoteApp
//
//  Created by sonnd on 10/3/25.
//

import UIKit


extension UIView {
    var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
}
