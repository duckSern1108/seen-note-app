//
//  SingleNoteVC.swift
//  SernNoteApp
//
//  Created by sonnd on 8/3/25.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit
import Domain


class SingleNoteVC: UIViewController {
    
    static func newVC(viewModel: SingleNoteVM) -> SingleNoteVC {
        let vc = SingleNoteVC()
        vc.viewModel = viewModel
        return vc
    }
    
    private lazy var titleView = {
        let ret = FloatingInputView()
        ret.bindUIConfig(.init(title: "Title"))
        return ret
    }()
    private lazy var contentTextView = {
        let ret = FloatingTextView()
        ret.title = "Content"
        ret.textContainerInset = .init(top: 24, left: 8, bottom: 8, right: 8)
        ret.font = .systemFont(ofSize: 15)
        return ret
    }()
    
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
        
        view.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges).inset(16)
        }
        
        view.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
        
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
    }
    
    private func bindViewModel() {
        let output = viewModel.transform(
            input: .init(
                titlePublisher: titleView.textField.textPublisher.map { $0 ?? "" }.eraseToAnyPublisher(),
                contentPublisher: contentTextView.textPublisher.map { $0 ?? "" }.eraseToAnyPublisher(),
                backPublisher: backPublisher.eraseToAnyPublisher()
            ))
        
        output.notePublisher.map { $0.content }
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: contentTextView)
            .store(in: &cancellations)
        
        output.notePublisher.map { $0.title }
            .receive(on: DispatchQueue.main)
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
