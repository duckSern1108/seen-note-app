//
//  BaseWithoutNibView.swift
//  SernNoteApp
//
//  Created by sonnd on 10/3/25.
//

import UIKit

class WithoutNibView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        
    }
}
