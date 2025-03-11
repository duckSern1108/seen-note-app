//
//  GAMPPackageInputView.swift
//  GAMPCreatePackModule
//
//  Created by sonnd92 on 10/3/25.
//

import UIKit
import SnapKit
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
        textField.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(20)
        }
        
        addSubview(stackViewContainer)
        stackViewContainer.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(10)
        }
        
        stackViewContainer.addArrangedSubview(textFieldContainer)
        textFieldContainer.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
        }
        
        let closeImageView = UIImageView(image: UIImage(systemName: "xmark"))
        closeImageView.contentMode = .scaleAspectFit
        closeImageView.tintColor = .black
        stackViewContainer.addArrangedSubview(closeImageContainerView)
        closeImageContainerView.addSubview(closeImageView)
        closeImageContainerView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
        }
        closeImageView.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.center.equalToSuperview()
        }
        closeImageContainerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        closeButton.translatesAutoresizingMaskIntoConstraints = false
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
        titleLabel.frame.origin.y = bounds.midY - titleLabel.frame.height / 2
        titleLabel.frame.origin.x = 16
        if !(textField.text ?? "").isEmpty {
            setupUIWhenTextNotEmpty()
        }
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
