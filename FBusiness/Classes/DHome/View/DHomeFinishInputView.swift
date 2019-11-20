//
//  DHomeFinishInputView.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/27.
//

import UIKit
import SwiftX

class DHomeFinishInputView: UIView {
    
    typealias FinishInputHandler = ((_ code: String) -> Void)
    
    private let contentViewHeight: CGFloat = (UIScreen.width * 3 / 4)
    
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var heightContentConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContentConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var SNoLabel: UILabel!
    
    var handler: FinishInputHandler?
    
    private lazy var codeField: XValidationTextField = {
        let field = XValidationTextField(frame: CGRect(x: 0, y: 0, width: UIScreen.width - 60, height: 44))
        field.itemSpacing = UIDevice.isIphone4_5() ? 15 : 18
        field.delegate = self
        return field
    }()
    
    class func loadFromXib() -> DHomeFinishInputView {
        if let view = Bundle.currentDHome.loadNibNamed("DHomeFinishInputView", owner: self, options: nil)?.first as? DHomeFinishInputView {
            view.frame = UIScreen.main.bounds
            return view
        }
        return DHomeFinishInputView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        opacityView.alpha = 0.01
        heightContentConstraint.constant = contentViewHeight
        
        codeView.addSubview(codeField)
        
        _ = NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                self?._keyboardWillChangeFrame(notification)
            })
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        _dismiss()
    }
}

extension DHomeFinishInputView {
    
    private func _show() {
        self.frame = currentViewController?.view.bounds ?? UIScreen.main.bounds
        currentViewController?.view.addSubview(self)
        opacityView.alpha = 0.01
        bottomContentConstraint.constant = 150 + UIScreen.homeIndicatorMoreHeight
        codeField.becomeFirstResponder()
        UIView.animate(withDuration: 0.25, animations: {
            self.opacityView.alpha = 0.7
            self.layoutIfNeeded()
        }) { (_) in
        }
    }
    
    private func _dismiss(_ agreed: Bool = false) {
        bottomContentConstraint.constant = -contentViewHeight
        codeField.resignFirstResponder()
        UIView.animate(withDuration: 0.25, animations: {
            self.opacityView.alpha = 0.01
            self.layoutIfNeeded()
        }) { (_) in
            self.removeFromSuperview()
            self.codeField.clear()
        }
    }
    
    private func _keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let endY = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.origin.y ?? 0
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
        
        bottomContentConstraint.constant = -contentViewHeight
        if endY != UIScreen.height {
            bottomContentConstraint.constant = 150 + UIScreen.homeIndicatorMoreHeight
        }
        UIView.animate(withDuration: duration, animations: {
            self.layoutIfNeeded()
        })
    }
    
}

extension DHomeFinishInputView {
    
    func show(with SNo: String) {
        let attributedString = NSMutableAttributedString(string: "运单编号：\(SNo)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor(hexColor: "#666666")])
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(hexColor: "#333333")], range: NSMakeRange(0, 5))
        SNoLabel.attributedText = attributedString
        _show()
    }
    
    func dismiss() {
        _dismiss()
    }
    
}

extension DHomeFinishInputView: XValidationTextFieldDelegate {
    
    func validationTextFieldDidFinishInput(_ textField: XValidationTextField) {
        handler?(textField.text)
    }
    
}
