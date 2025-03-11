//
//  NoteListHeaderView.swift
//  SernNoteApp
//
//  Created by sonnd on 10/3/25.
//

import UIKit

final class NoteListHeaderView: UITableViewHeaderFooterView {
    // label's height = 24, vertical padding = 8
    static let HEIGHT: CGFloat = 40
    private let label = UILabel()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(label)
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func bind(_ data: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLL yyyy"
        label.text = formatter.string(from: data)
    }
}
