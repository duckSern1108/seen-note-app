//
//  NoteListHeaderView.swift
//  SernNoteApp
//
//  Created by sonnd on 10/3/25.
//

import UIKit
import SnapKit


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
        label.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview()
        }
    }
    
    func bind(_ data: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLL yyyy"
        label.text = formatter.string(from: data)
    }
}
