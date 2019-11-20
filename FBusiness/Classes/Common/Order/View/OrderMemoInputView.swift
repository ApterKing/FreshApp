//
//  OrderMemoInputView.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class OrderMemoInputView: UIView {
    
    typealias InputDoneHandler = ((_ text: String) -> Void)

    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!
    
    private let contentViewHeight: CGFloat = 140
    var handler: InputDoneHandler?
    
    class func loadFromXib() -> OrderMemoInputView {
        if let view = Bundle.currentCommon.loadNibNamed("OrderMemoInputView", owner: self, options: nil)?.first as? OrderMemoInputView {
            view.frame = UIScreen.main.bounds
            view.contentBottomConstraint.constant = 0
            return view
        }
        return OrderMemoInputView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        opacityView.addGestureRecognizer(gesture)
        
        _ = gesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.textView.resignFirstResponder()
                self?.dismiss()
            })
        
        _ = NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                self?._keyboardWillChangeFrame(notification)
            })
    }
    
}

extension OrderMemoInputView {
    
    private func _show() {
        self.frame = topViewController?.view.bounds ?? UIScreen.main.bounds
        topViewController?.view.addSubview(self)
        opacityView.alpha = 0.01
        contentBottomConstraint.constant = 0
        self.textView.becomeFirstResponder()
        UIView.animate(withDuration: 0.25, animations: {
            self.opacityView.alpha = 0.7
        }) { (_) in
        }
    }
    
    private func _dismiss() {
        textView.resignFirstResponder()
        contentBottomConstraint.constant = -contentViewHeight
        UIView.animate(withDuration: 0.25, animations: {
            self.opacityView.alpha = 0.01
            self.layoutIfNeeded()
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    private func _keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let endY = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.origin.y ?? 0
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
        
        var targetBottom: CGFloat = 0
        if endY != UIScreen.height {
            targetBottom = UIScreen.height - endY
        }
        contentBottomConstraint.constant = targetBottom
        UIView.animate(withDuration: duration, animations: {
            self.layoutIfNeeded()
        })
    }
    
}

extension OrderMemoInputView {
    
    func show(with text: String?) {
        textView.text = text
        placeholderLabel.isHidden = text != nil

        _show()
    }
    
    func dismiss() {
        _dismiss()
    }
    
}

extension OrderMemoInputView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            handler?(textView.text)
            textView.resignFirstResponder()
            dismiss()
            return false
        } else {
            var targetStr = NSString(string: textView.text).replacingCharacters(in: range, with: text)
            
            placeholderLabel.isHidden = textView.text != "" || text != ""
            let memo = targetStr.trimmingCharacters(in: CharacterSet.whitespaces)
            if memo.count > 100 {
                let targetIndex = targetStr.index(targetStr.startIndex, offsetBy: 100)
                targetStr = String(targetStr.prefix(upTo: targetIndex))
            }
            textView.text = targetStr
            return false
        }
    }
    
}
