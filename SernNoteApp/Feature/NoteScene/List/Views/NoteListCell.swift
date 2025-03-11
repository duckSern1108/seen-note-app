//
//  NoteListCell.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import UIKit
import SnapKit
import Domain


final class NoteListCell: UITableViewCell {
    
    /*
     16: vertical padding
     20: label height
     8: spacing stackview
     44: height of title's stackview
     16 * 2 + 20 + 8 + 44
     */
    static let HEIGHT: CGFloat = 104
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    private lazy var contentLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray2
        return label
    }()
    private lazy var timeLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.setContentHuggingPriority(.defaultLow + 1, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        return label
    }()
    private lazy var monthLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    private lazy var dayLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    private func setup() {
        selectionStyle = .none
        
        let stackViewContainer = {
            let ret = UIStackView()
            ret.axis = .vertical
            ret.spacing = 8
            return ret
        }()
        contentView.addSubview(stackViewContainer)
        stackViewContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        let infoStackView = {
            let ret = UIStackView()
            ret.axis = .horizontal
            ret.spacing = 8
            return ret
        }()
        stackViewContainer.addArrangedSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        stackViewContainer.addArrangedSubview(contentLabel)
        let dayContainerView = {
            let v = UIView()
            v.cornerRadius = 8
            v.backgroundColor = .init(hex: 0xF1F1F1)
            return v
        }()
        dayContainerView.addSubview(monthLabel)
        dayContainerView.snp.makeConstraints { make in
            make.width.equalTo(dayContainerView.snp.height)
        }
        monthLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(4)
        }
        dayContainerView.addSubview(dayLabel)
        dayLabel.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview().inset(4)
        }
        infoStackView.addArrangedSubview(dayContainerView)
        let titleStackView = {
            let ret = UIStackView()
            ret.axis = .vertical
            ret.spacing = 4
            return ret
        }()
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(timeLabel)
        infoStackView.addArrangedSubview(titleStackView)
    }
    
    func bindNote(_ data: NoteModel) {
        titleLabel.text = data.title.isEmpty ? "Title empty" : data.title
        contentLabel.text = data.content.isEmpty ? "Content empty" : data.content
        contentLabel.textColor = data.content.isEmpty ? .systemGray : .black
        timeLabel.text = "\(data.created.hour24):\(data.created.minute0x)"
        dayLabel.text = "\(data.created.day)"
        monthLabel.text = data.created.monthMedium
    }
}
