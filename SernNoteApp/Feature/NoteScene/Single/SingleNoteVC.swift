//
//  SingleNoteVC.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import UIKit
import Combine
import CombineCocoa


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
    
    private var voidPub = PassthroughSubject<Void, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onDone))
        view.backgroundColor = .init(hex: 0xF1F1F1)
        
        contentTextView.title = "Content"
        contentTextView.textContainerInset = .init(top: 24, left: 8, bottom: 8, right: 8)
        
        viewModel.bind(
            input: .init(
                titlePublisher: titleView.textField.textPublisher.map { $0 ?? "" }.eraseToAnyPublisher(),
                contentPublisher: contentTextView.textPublisher.map { $0 ?? "" }.eraseToAnyPublisher(),
                backPublisher: voidPub.eraseToAnyPublisher(),
                donePublisher: voidPub.eraseToAnyPublisher()),
            cancellations: &cancellations)
        
        titleView.bindUIConfig(.init(title: "Title"))
        titleView.bindInput(.init(
            textObservable: viewModel.$title.map { $0 as String? }.eraseToAnyPublisher()
        ))
        
        bindViewModel()
    }
    
    @objc private func onDone() {
        view.endEditing(true)
    }
    
    private func bindViewModel() {
        viewModel.$note.map { $0.content }
            .assign(to: \.text, on: contentTextView)
            .store(in: &cancellations)
        
        viewModel.$note.map { $0.title }
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                self.titleView.textField.text = $0
                self.titleView.textField.sendActions(for: .valueChanged)
            })
            .store(in: &cancellations)
        
        viewModel.$note
            .map { ($0.title.isEmpty && $0.content.isEmpty) ? "Add note" : "Edit note" }
            .assign(to: \.title, on: navigationItem)
            .store(in: &cancellations)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        voidPub.send(())
    }
    
}
