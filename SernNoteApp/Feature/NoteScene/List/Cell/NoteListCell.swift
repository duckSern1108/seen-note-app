//
//  NoteListCell.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import UIKit

final class NoteListCell: UITableViewCell {
    
    /*
     16: vertical padding
     20: label height
     8: spacing stackview
     44: height of title's stackview
     16 * 2 + 20 + 8 + 44
     */
    static let HEIGHT: CGFloat = 104
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var dayContainerView: UIView!
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var dayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        dayContainerView.cornerRadius = 8
    }
    
    func bindNote(_ data: NoteModel) {
        titleLabel.text = data.title
        contentLabel.text = data.content.isEmpty ? "Content empty" : data.content
        contentLabel.textColor = data.content.isEmpty ? .systemGray : .black
        timeLabel.text = "\(data.created.hour24):\(data.created.minute0x)"
        dayLabel.text = "\(data.created.day)"
        monthLabel.text = data.created.monthMedium
    }
}
