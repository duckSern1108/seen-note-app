//
//  UIColor+Ext.swift
//  SernNoteApp
//
//  Created by sonnd on 10/3/25.
//

import UIKit


extension UIColor {
    convenience init(hex: Int) {
        self.init(
            red: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255,
            alpha: CGFloat(1))
    }
}
