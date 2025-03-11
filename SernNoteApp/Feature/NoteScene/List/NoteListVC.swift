//
//  NoteListVC.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import UIKit
import Combine
import CombineCocoa
import Domain


final class NoteListVC: UIViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<Date, NoteModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Date, NoteModel>
    
    @IBOutlet private weak var searchContainer: UIStackView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var tableview: UITableView!
    
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
        
        searchContainer.cornerRadius = 8
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(onAdd))
        
        tableview.backgroundColor = .clear
        tableview.register(UINib(nibName: "NoteListCell", bundle: nil), forCellReuseIdentifier: "NoteListCell")
        tableview.register(NoteListHeaderView.self, forHeaderFooterViewReuseIdentifier: "NoteListHeaderView")
        tableview.delegate = self
        datasource = .init(tableView: tableview, cellProvider: { tableview, indexPath, item in
            let cell = tableview.dequeueReusableCell(withIdentifier: "NoteListCell", for: indexPath) as! NoteListCell
            cell.bindNote(item)
            return cell
        })
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
            .receive(on: DispatchQueue.main)
            .flatMap { NoteListVCUIDataGenerator(data: $0).publiser }
            .sink { [weak self] data in
                self?.reloadList(data: data)
            }
            .store(in: &cancellations)
        
        output.loadPubliser
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellations)
        
        output.addNotePublisher
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellations)
        
        output.editNotePublisher
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
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
        guard let section = datasource.sectionIdentifier(for: section),
              let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NoteListHeaderView") as? NoteListHeaderView
        else { return nil }
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


