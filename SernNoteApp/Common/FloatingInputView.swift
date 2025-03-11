//
//  GAMPPackageInputView.swift
//  GAMPCreatePackModule
//
//  Created by sonnd92 on 10/3/25.
//

import UIKit
import Combine
import CombineCocoa


class FloatingInputView: WithoutNibView {
    
    struct UIConfig {
        var title: String = ""
    }
    
    struct Input {
        var textObservable: AnyPublisher<String?, Never>
    }
    
    lazy var textField = {
        let ret = UITextField()
        ret.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        ret.font = .systemFont(ofSize: 15)
        ret.borderStyle = .none
        return ret
    }()
    private lazy var titleLabel = {
        let ret = UILabel()
        ret.font = .systemFont(ofSize: 15)
        ret.textColor = UIColor(hex: 0x5A5A5A)
        ret.frame = .init(origin: .zero, size: .init(width: 200, height: 20))
        return ret
    }()
    private lazy var closeImageContainerView = UIView()
    private lazy var closeButton = UIButton()
    
    private var cancellations = Set<AnyCancellable>()
    
    override func setup() {
        super.setup()
        
        cornerRadius = 8
        backgroundColor = .white
        
        let stackViewContainer = {
            let ret = UIStackView()
            ret.axis = .horizontal
            ret.spacing = 8
            ret.alignment = .center
            return ret
        }()
        let textFieldContainer = UIView()
        textFieldContainer.addSubview(textField)
        textField.alpha = 0
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        addSubview(stackViewContainer)
        stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackViewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
        
        stackViewContainer.addArrangedSubview(textFieldContainer)
        textFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textFieldContainer.topAnchor.constraint(equalTo: stackViewContainer.topAnchor),
            textFieldContainer.bottomAnchor.constraint(equalTo: stackViewContainer.bottomAnchor),
        ])
        
        let closeImageView = UIImageView(image: UIImage(systemName: "xmark"))
        closeImageView.contentMode = .scaleAspectFit
        closeImageView.tintColor = .black
        stackViewContainer.addArrangedSubview(closeImageContainerView)
        closeImageContainerView.addSubview(closeImageView)
        NSLayoutConstraint.activate([
            closeImageContainerView.widthAnchor.constraint(equalToConstant: 20),
            closeImageContainerView.heightAnchor.constraint(equalToConstant: 20)
        ])
        closeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeImageView.heightAnchor.constraint(equalToConstant: 16),
            closeImageView.centerYAnchor.constraint(equalTo: closeImageContainerView.centerYAnchor),
            closeImageView.centerXAnchor.constraint(equalTo: closeImageContainerView.centerXAnchor)
        ])
        
        closeImageContainerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: closeImageContainerView.leadingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: closeImageContainerView.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: closeImageContainerView.topAnchor),
            closeButton.bottomAnchor.constraint(equalTo: closeImageContainerView.bottomAnchor),
        ])
        closeImageContainerView.isHidden = true
        
        addSubview(titleLabel)
        
        bindAction()
    }
    
    func bindUIConfig(_ config: UIConfig) {
        titleLabel.text = config.title
    }
    
    func bindInput(_ input: Input) {
        input.textObservable
            .assign(to: \.text, on: textField)
            .store(in: &cancellations)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !textField.isEditing else { return }
        titleLabel.bounds.size.width = bounds.size.width - 16 * 2
        titleLabel.frame.origin.x = 16
    }
    
    private func bindAction() {
        Publishers.Merge(textField.didBeginEditingPublisher, textField.controlEventPublisher(for: .editingDidEnd))
            .withLatestFrom(textField.textPublisher.map { $0 ?? "" }, resultSelector: { $1 })
            .sink { [weak self] text in
                guard let self = self else { return }
                if self.textField.isEditing {
                    self.closeImageContainerView.isHidden = false
                    UIView.animate(withDuration: 0.2) {
                        self.layer.borderWidth = 1
                        self.layer.borderColor = UIColor.green.cgColor
                    }
                    if text.isEmpty {
                        UIView.animate(withDuration: 0.2) {
                            self.setupUIWhenTextNotEmpty()
                        }
                    }
                } else {
                    self.closeImageContainerView.isHidden = true
                    UIView.animate(withDuration: 0.2) {
                        self.layer.borderWidth = 0
                        self.layer.borderColor = UIColor.clear.cgColor
                    }
                    if text.isEmpty {
                        UIView.animate(withDuration: 0.2) {
                            self.textField.alpha = 0
                            self.titleLabel.frame.origin.y = self.bounds.midY - self.titleLabel.frame.height / 2
                            self.titleLabel.transform = .identity
                            self.titleLabel.frame.origin.x = 16
                        }
                    }
                }
            }
            .store(in: &cancellations)
        
        textField.textPublisher.filter { !($0 ?? "").isEmpty }
            .sink { [weak self] _ in
                self?.setupUIWhenTextNotEmpty()
            }
            .store(in: &cancellations)
        
        closeButton.tapPublisher
            .map { "" }
            .assign(to: \.text, on: textField)
            .store(in: &cancellations)
        
        
        let tapGR = UITapGestureRecognizer()
        
        tapGR.tapPublisher
            .sink { [weak self] _ in
                self?.textField.becomeFirstResponder()
            }
            .store(in: &cancellations)
        addGestureRecognizer(tapGR)
    }
    
    private func setupUIWhenTextNotEmpty() {
        textField.alpha = 1
        titleLabel.frame.origin.y = 10
        titleLabel.transform = .identity.scaledBy(x: 0.8, y: 0.8)
        titleLabel.frame.origin.x = 16
    }
}
