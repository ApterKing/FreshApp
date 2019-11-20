//
//  DRegisterViewController.swift
//  FBusiness
//
//  Created by wangcong on 2019/2/18.
//

import UIKit
import SwiftX
import RxSwift
import RxCocoa
import Toaster

class DRegisterViewController: BaseViewController {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var codeButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    private let registerVModel = DRegisterVModel()
    private var timerDisposable: Disposable?

    override public func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardObserver()
        
        _initUI()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        Theme.decorate(field: phoneField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: codeField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)

        Theme.decorate(button: registerButton)
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        view.endEditing(true)
        if sender.tag == 0 {
            _getCheckCode()
        } else if sender.tag == 1 {
            _regist()
        } else {
            
        }
    }
    
}

extension DRegisterViewController {
    
    private func _initUI() {
        navigationItemBackStyle = .backGray
        navigationItem.title = "注册"
        
        let options: [UIControlStateOption] = [.title("登录", UIColor(hexColor: "#66B30C"), .normal),
                                               .title("登录", UIColor(hexColor: "#a0a0a5"), .disabled),
                                               .title("登录", UIColor(hexColor: "#66B30C").withAlphaComponent(0.7), .highlighted)
        ]
        navigationItem.rightBarButtonItem = customBarButtonItem(options: options, size: CGSize(width: 60, height: 44), isBackItem: false, left: false, handler: { [weak self] (_) in
            self?.navigationController?.popViewController(animated: true)
        })
        
        _ = Observable.combineLatest(phoneField.rx.text.asObservable(), codeField.rx.text.asObservable()) { (phone, code) -> (String, String) in
                return (phone ?? "", code ?? "")
            }.takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (element) in
                guard let weakSelf = self else { return }
                weakSelf.codeButton.isEnabled = element.0.count == 11
                
                weakSelf.registerButton.isEnabled = element.0.count == 11 && element.1.count == 6
            })
        
        _ = NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                self?._keyboardWillChangeFrame(notification)
            })
    }
    
    private func _keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let endY = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.origin.y ?? 0
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
        
        topConstraint.constant = 25
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }

    private func _getCheckCode() {
        guard let phone = phoneField.text else { return }
        startHUDAnimation()
        registerVModel.checkCode(phone) { [weak self] (model, error) in
            guard let weakSelf = self else { return }
            weakSelf.stopHUDAnimation()
            if model?.code == 200 {
                Toast.message("验证码已发送，请注意您的短信")
                weakSelf.timerDisposable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                    .take(61)
                    .subscribe(onNext: { (interval) in
                        weakSelf.codeButton.isEnabled = interval >= 60
                        weakSelf.codeButton.titleLabel?.text = interval < 60 ? "\(60 - interval)s 后重发" : "重新获取"
                        weakSelf.codeButton.setTitle(interval < 60 ? "\(60 - interval)s 后重发" : "重新获取", for: .normal)
                    })
            }
        }
    }
    
    private func _regist() {
        guard phoneField.text?.count ?? 0  == 11 else {
            Toast.message("请输入11位手机号码")
            return
        }
        guard codeField.text?.count ?? 0  == 6 else {
            Toast.message("请输入6位验证码")
            return
        }
        startHUDAnimation()
        registerVModel.regist(phoneField.text!, codeField.text!) { [weak self] (token, error) in
            self?.stopHUDAnimation()
            if error == nil {
                Toast.message("注册成功")
                currentNavigationController?.popViewController(animated: true)
            }
        }
    }
    
}

extension DRegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == phoneField || textField == codeField {
            textField.keyboardType = .numberPad
        } else {
            textField.keyboardType = .asciiCapable
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        Theme.decorate(field: phoneField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: codeField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: textField, shadowColor: UIColor(hexColor: "#66B30C"), borderColor: UIColor(hexColor: "#66B30C"))
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var targetStr = NSString(string: textField.attributedText?.string ?? "").replacingCharacters(in: range, with: string)
        
        if textField == phoneField {
            let text = targetStr.trimmingCharacters(in: CharacterSet.whitespaces)
            if text.count > 11 {
                let targetIndex = targetStr.index(targetStr.startIndex, offsetBy: 11)
                targetStr = String(targetStr.prefix(upTo: targetIndex))
                textField.text = targetStr
                return false
            }
            return true
        } else if textField == codeField {
            let text = targetStr.trimmingCharacters(in: CharacterSet.whitespaces)
            if text.count > 6 {
                let targetIndex = targetStr.index(targetStr.startIndex, offsetBy: 6)
                targetStr = String(targetStr.prefix(upTo: targetIndex))
                textField.text = targetStr
                return false
            }
            return true
        }
        return false
    }
    
}
