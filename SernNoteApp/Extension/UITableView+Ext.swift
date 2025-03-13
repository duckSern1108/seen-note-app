//
//  UITableView+Ext.swift
//  SernNoteApp
//
//  Created by sonnd on 11/3/25.
//

import UIKit

extension UITableView {
    func registerCell<T: UITableViewCell>(_ type: T.Type) {
        register(type, forCellReuseIdentifier: NSStringFromClass(T.self))
    }
    
    func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: NSStringFromClass(T.self), for: indexPath) as! T
    }
    
    func registerHeaderFooterView<T: UITableViewHeaderFooterView>(_ type: T.Type) {
        register(type, forHeaderFooterViewReuseIdentifier: NSStringFromClass(T.self))
    }
    
    func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(T.self)) as! T
    }
}
