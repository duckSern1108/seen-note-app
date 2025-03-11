//
//  NoteListVC.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit
import Domain


final class NoteListVC: UIViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<Date, NoteModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Date, NoteModel>
    
    private lazy var textField = {
        let ret = UITextField()
        ret.borderStyle = .none
        ret.placeholder = "Search note"
        return ret
    }()
    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var cancelButton = {
        let ret = UIButton()
        ret.setTitle("Cancel", for: .normal)
        ret.setTitleColor(.systemBlue, for: .normal)
        ret.isHidden = true
        return ret
    }()
    
    static func newVC(viewModel: NoteListVM) -> NoteListVC {
        let vc = NoteListVC()
        vc.viewModel = viewModel
        return vc
    }
    
    private let syncListNotePublisher: PassthroughSubject<Void, Never> = .init()
    private let selectNotePublisher: PassthroughSubject<NoteModel, Never> = .init()
    private let deleteNotePublisher: PassthroughSubject<NoteModel, Never> = .init()
    private let addNotePublisher: PassthroughSubject<Void, Never> = .init()
    
    private var viewModel: NoteListVM!
    
    private var datasource: DataSource!
    private var cancellations = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        bindViewModel()
    }
    
    private func setupUI() {
        title = "Note list"
        view.backgroundColor = .init(hex: 0xF1F1F1)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(onAdd))
        
        let searchContainerView = {
            let ret = UIStackView()
            ret.axis = .horizontal
            ret.spacing = 8
            return ret
        }()
        view.addSubview(searchContainerView)
        searchContainerView.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges).inset(16)
        }
        let searchFieldContainerView = {
            let ret = UIStackView()
            ret.backgroundColor = .systemGray3
            ret.cornerRadius = 8
            ret.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
            ret.axis = .horizontal
            ret.spacing = 0
            return ret
        }()
        searchContainerView.addArrangedSubview(searchFieldContainerView)
        searchContainerView.addArrangedSubview(cancelButton)
        let searchImgView = {
            let ret = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            ret.contentMode = .center
            ret.tintColor = .systemGray
            return ret
        }()
        searchFieldContainerView.addArrangedSubview(searchImgView)
        searchFieldContainerView.addArrangedSubview(textField)
        searchImgView.snp.makeConstraints { make in
            make.width.equalTo(searchImgView.snp.height)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchFieldContainerView.snp.bottom).offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges)
        }
        
        tableView.registerCell(NoteListCell.self)
        tableView.registerHeaderFooterView(NoteListHeaderView.self)
        tableView.delegate = self
        datasource = .init(tableView: tableView, cellProvider: { tableView, indexPath, item in
            let cell: NoteListCell = tableView.dequeueCell(for: indexPath)
            cell.bindNote(item)
            return cell
        })
        
        KeyboardCombine.heightPublisher
            .sink { [weak self] height in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.25, animations: {
                    if height > 0 {
                        self.additionalSafeAreaInsets.bottom = height - self.view.safeAreaInsets.bottom + 16
                    } else {
                        self.additionalSafeAreaInsets.bottom = 0
                    }
                })
            }
            .store(in: &cancellations)
        
        cancelButton.tapPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                self.textField.text = ""
                self.view.endEditing(true)
            }
            .store(in: &cancellations)
        
        textField.didBeginEditingPublisher
            .map { _ in false }
            .assign(to: \.isHidden, on: cancelButton)
            .store(in: &cancellations)
        
        textField.controlEventPublisher(for: .editingDidEnd)
            .map { _ in true }
            .assign(to: \.isHidden, on: cancelButton)
            .store(in: &cancellations)
    }
    
    private func bindViewModel() {
        let output = viewModel.transform(
            input: .init(
                searchQuery: textField.textPublisher.map { $0 ?? "" }.eraseToAnyPublisher(),
                syncListNotePublisher: syncListNotePublisher.eraseToAnyPublisher(),
                addNotePublisher: addNotePublisher.eraseToAnyPublisher(),
                selectNotePublisher: selectNotePublisher.eraseToAnyPublisher(),
                deleteNotePublisher: deleteNotePublisher.eraseToAnyPublisher()
            ))
        
        output.listNotePubliser
            .flatMap { NoteListVCUIDataGenerator(data: $0).publiser }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.reloadList(data: data)
            }
            .store(in: &cancellations)
        
        output.loadPubliser
            .sink(receiveValue: { _ in })
            .store(in: &cancellations)
        
        output.addNotePublisher
            .sink(receiveValue: { _ in })
            .store(in: &cancellations)
        
        output.editNotePublisher
            .sink(receiveValue: { _ in })
            .store(in: &cancellations)
        
        output.deleteNotePublisher
            .sink(receiveValue: { _ in })
            .store(in: &cancellations)
        
        syncListNotePublisher.send(())
    }
    
    private func reloadList(data: (sections: [Date], map:[Date: [NoteModel]])) {
        var snapshot = Snapshot()
        snapshot.appendSections(data.sections)
        for section in data.sections {
            if let items = data.map[section] {
                snapshot.appendItems(items, toSection: section)
            }
        }
        datasource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc private func onAdd() {
        addNotePublisher.send(())
    }
}

extension NoteListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return }
        selectNotePublisher.send(item)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self, indexPath] (action, view, completionHandler) in
            self?.deleteNote(indexPath: indexPath)
            completionHandler(true)
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        NoteListCell.HEIGHT
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = datasource.sectionIdentifier(for: section)
        else { return nil }
        let cell: NoteListHeaderView = tableView.dequeueHeaderFooterView()
        cell.bind(section)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        NoteListHeaderView.HEIGHT
    }
}

extension NoteListVC {
    private func deleteNote(indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return }
        deleteNotePublisher.send(item)
    }
}


