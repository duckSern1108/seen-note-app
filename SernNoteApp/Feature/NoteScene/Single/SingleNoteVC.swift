//
//  SingleNoteVC.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import UIKit
import Combine
import CombineCocoa
import Domain


class SingleNoteVC: UIViewController {
    
    static func newVC(viewModel: SingleNoteVM) -> SingleNoteVC {
        let vc = SingleNoteVC()
        vc.viewModel = viewModel
        return vc
    }
    
    @IBOutlet private weak var titleView: FloatingInputView!
    @IBOutlet private weak var contentTextView: FloatingTextView!
    
    private var viewModel: SingleNoteVM!
    private var cancellations = Set<AnyCancellable>()
    
    private let _backPublisher = PassthroughSubject<Void, Never>()
    private var backPublisher: AnyPublisher<Void, Never> { _backPublisher.eraseToAnyPublisher() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    @objc private func onDone() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onDone))
        view.backgroundColor = .init(hex: 0xF1F1F1)
        
        contentTextView.title = "Content"
        contentTextView.textContainerInset = .init(top: 24, left: 8, bottom: 8, right: 8)
        
        titleView.bindUIConfig(.init(title: "Title"))
    }
    
    private func bindViewModel() {
        let output = viewModel.transform(
            input: .init(
                titlePublisher: titleView.textField.textPublisher.map { $0 ?? "" }.eraseToAnyPublisher(),
                contentPublisher: contentTextView.textPublisher.map { $0 ?? "" }.eraseToAnyPublisher(),
                backPublisher: backPublisher.eraseToAnyPublisher()
            ))
        
        output.notePublisher.map { $0.content }
            .assign(to: \.text, on: contentTextView)
            .store(in: &cancellations)
        
        output.notePublisher.map { $0.title }
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                self.titleView.textField.text = $0
                self.titleView.textField.sendActions(for: .valueChanged)
            })
            .store(in: &cancellations)
        
        output.notePublisher
            .map { ($0.title.isEmpty && $0.content.isEmpty) ? "Add note" : "Edit note" }
            .assign(to: \.title, on: navigationItem)
            .store(in: &cancellations)
        
        output.backPublisher
            .sink { _ in }
            .store(in: &cancellations)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _backPublisher.send(())
    }
    
}
