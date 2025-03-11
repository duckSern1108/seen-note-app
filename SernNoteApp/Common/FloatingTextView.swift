import UIKit
import CombineCocoa

final class FloatingTextView: UITextView {
    
    public let placeholderLabel: UILabel = UILabel()
    public let titleLabel: UILabel = UILabel()
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    override var text: String! {
        didSet {
            if !text.isEmpty {
                setupUIWhenTextNotEmpty()
            }
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            updateLabel()
        }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidBeginEditing),
                                               name: UITextView.textDidBeginEditingNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidEndEditing),
                                               name: UITextView.textDidEndEditingNotification,
                                               object: nil)
        cornerRadius = 8
        addSubview(titleLabel)
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.textColor = UIColor(hex: 0x5A5A5A)
        titleLabel.frame = .init(origin: .zero, size: .init(width: 0, height: 20))
    }
    
    @objc private func textDidBeginEditing() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.green.cgColor
        UIView.animate(withDuration: 0.2) {
            self.setupUIWhenTextNotEmpty()
        }
        
    }
    
    private func setupUIWhenTextNotEmpty() {
        titleLabel.transform = .identity.scaledBy(x: 0.8, y: 0.8)
        titleLabel.frame.origin.x = textContainerInset.left + textContainer.lineFragmentPadding
        titleLabel.frame.origin.y = textContainerInset.top - titleLabel.frame.height
    }
    
    @objc private func textDidEndEditing() {
        self.layer.borderWidth = 0
        guard text.isEmpty else { return }
        UIView.animate(withDuration: 0.2) {            
            self.titleLabel.transform = .identity
            self.titleLabel.frame.origin.x = self.textContainerInset.left + self.textContainer.lineFragmentPadding
            self.titleLabel.frame.origin.y = self.textContainerInset.top
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        placeholderLabel.bounds.size.width = textContainer.size.width - textContainerInset.left - textContainerInset.right
        titleLabel.bounds.size.width = textContainer.size.width - textContainerInset.left - textContainerInset.right
        titleLabel.frame.origin.x = textContainerInset.left + textContainer.lineFragmentPadding
        placeholderLabel.frame.origin.x = textContainerInset.left + textContainer.lineFragmentPadding
        
    }
    
    private func updateLabel() {
        titleLabel.frame.origin.x = textContainerInset.left + textContainer.lineFragmentPadding
        titleLabel.frame.origin.y = textContainerInset.top
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
