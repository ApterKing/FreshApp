//
//  ResetPasswordViewController.swift
//  FBusiness
//
//

import UIKit
import RxSwift
import RxCocoa
import SwiftX
import Toaster

class ResetPasswordViewController: BaseViewController {
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var oldPwdField: UITextField!
    @IBOutlet weak var newPwdField: UITextField!
    @IBOutlet weak var confirmPwdField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    
    private let vmodel = ResetVModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardObserver()
        
        _initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Theme.decorate(field: oldPwdField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: newPwdField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: confirmPwdField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        
        Theme.decorate(button: resetButton)
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        view.endEditing(true)
        _reset()
    }
    
}

extension ResetPasswordViewController {
    
    private func _initUI() {
        navigationItem.title = "修改密码"
        
        _ = Observable.combineLatest(oldPwdField.rx.text.asObservable(), newPwdField.rx.text, confirmPwdField.rx.text) { (oldPwd, newPwd, confirmPwd) -> (String, String, String) in
                return (oldPwd ?? "", newPwd ?? "", confirmPwd ?? "")
            }.takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (element) in
                guard let weakSelf = self else { return }
                print("  \(element)")
                weakSelf.resetButton.isEnabled = element.0.count != 0 && element.1.count >= 6 && element.2.count != 0
            })
        
        _ = NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                self?._keyboardWillChangeFrame(notification)
            })
    }
    
    private func _reset() {
        guard let newPwdCount = newPwdField.text?.count else { return }
        guard oldPwdField.text?.count ?? 0  != 0 else {
            Toast.show("请输入原密码")
            return
        }
        guard newPwdCount >= 6, newPwdCount <= 18 else {
            Toast.show("密码需 6 ~ 18 位")
            return
        }
        guard confirmPwdField.text == newPwdField.text else {
            Toast.show("两次输入的新密码不匹配")
            return
        }
        startHUDAnimation()
        vmodel.reset(oldPwdField.text!, newPwdField.text!) { [weak self] (_, error) in
            guard let weakSelf = self else { return }
            weakSelf.stopHUDAnimation()
            if error == nil {
                topNavigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func _keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let endY = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.origin.y ?? 0
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
        
        var targetTop: CGFloat = 50
        if endY != UIScreen.height {
            targetTop = UIDevice.isIphone4_5() ? 30 : 40
        }
        topConstraint.constant = targetTop
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
}

extension ResetPasswordViewController {
    
    static public func show() {
        UserVModel.default.verify { (success) in
            if success {
                let vc = ResetPasswordViewController(nibName: "ResetPasswordViewController", bundle: Bundle.currentMine)
                vc.hidesBottomBarWhenPushed = true
                topNavigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

extension ResetPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.keyboardType = .asciiCapable
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        Theme.decorate(field: oldPwdField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: newPwdField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: confirmPwdField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: textField, shadowColor: UIColor(hexColor: "#66B30C"), borderColor: UIColor(hexColor: "#66B30C"))
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var targetStr = NSString(string: textField.attributedText?.string ?? "").replacingCharacters(in: range, with: string)
        
        let text = targetStr.trimmingCharacters(in: CharacterSet.whitespaces)
        if text.count > 18 {
            let targetIndex = targetStr.index(targetStr.startIndex, offsetBy: 18)
            targetStr = String(targetStr.prefix(upTo: targetIndex))
            textField.text = targetStr
            return false
        } else {
            return true
        }
    }
    
}
