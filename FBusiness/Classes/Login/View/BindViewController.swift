//
//  BindViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import RxSwift
import RxCocoa
import Toaster


class BindViewController: BaseViewController {
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var invitationField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var codeButton: UIButton!
    @IBOutlet weak var bindButton: UIButton!

    private let vmodel = BindVModel()
    private var timerDisposable: Disposable?

    var jsonResponse: [AnyHashable: Any]?
    var way: String?
    var handler: UserVModel.VerifyHandler?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardObserver()
        
        _initUI()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Theme.decorate(field: phoneField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: codeField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: invitationField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: passwordField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        
        Theme.decorate(button: bindButton)
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        view.endEditing(true)
        if sender.tag == 0 {
            _getCheckCode()
        } else if sender.tag == 1 {
            _bind()
        } else {
            
        }
    }
    
}

extension BindViewController {
    
    private func _initUI() {
        navigationItemBackStyle = .backGray
        navigationItem.title = "绑定手机号"
       
        _ = Observable.combineLatest(phoneField.rx.text.asObservable(), codeField.rx.text.asObservable(), passwordField.rx.text) { (phone, code, password) -> (String, String, String) in
            return (phone ?? "", code ?? "", password ?? "")
            }.takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (element) in
                guard let weakSelf = self else { return }
                weakSelf.codeButton.isEnabled = element.0.count == 11
                
                weakSelf.bindButton.isEnabled = element.0.count == 11 && element.1.count == 6 && element.2.count != 0
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
        
        var targetTop: CGFloat = 20
        if endY != UIScreen.height && (invitationField.isFirstResponder || passwordField.isFirstResponder) {
            targetTop = 0
        }
        topConstraint.constant = targetTop
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }

    
    private func _getCheckCode() {
        guard let phone = phoneField.text else { return }
        vmodel.checkCode(phone) { [weak self] (model, error) in
            guard let weakSelf = self else { return }
            if model?.code == 200 {
                Toast.show("验证码已发送，请注意您的短信")
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
    
    private func _bind() {
        let passwordCount = passwordField.text?.count ?? 0
        guard phoneField.text?.count ?? 0  == 11 else {
            Toast.show("请输入11位手机号码")
            return
        }
        guard codeField.text?.count ?? 0  == 6 else {
            Toast.show("请输入6位验证码")
            return
        }
        guard passwordCount >= 6, passwordCount <= 18 else {
            Toast.show("密码需 6 ~ 18 位")
            return
        }
        guard let way = way, let regId = jsonResponse?["unionid"] as? String, let jsonString = (try? JSONSerialization.string(with: jsonResponse)) as? String else {
            return
        }
        startHUDAnimation()
        vmodel.bind(way, regId, jsonString, phoneField.text!, codeField.text!, passwordField.text!, invitationField.text) { [weak self] (token, error) in
            self?.stopHUDAnimation()
            if error == nil {
                if CommissionVModel.default.currentCommission?.invitedDeductionDiscountConfig != CommissionModel.Config.none.rawValue && self?.invitationField.text != "" {
                    CommissionViewController.show(handler: self?.handler)
                } else {
                    self?.navigationController?.dismiss(animated: true, completion: {
                        self?.handler?(true)
                    })
                }
            }
        }
    }
    
}

extension BindViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == phoneField || textField == codeField {
            textField.keyboardType = .numberPad
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        Theme.decorate(field: phoneField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: codeField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: invitationField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: passwordField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
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
        } else if textField == passwordField {
            let text = targetStr.trimmingCharacters(in: CharacterSet.whitespaces)
            if text.count > 18 {
                let targetIndex = targetStr.index(targetStr.startIndex, offsetBy: 18)
                targetStr = String(targetStr.prefix(upTo: targetIndex))
                textField.text = targetStr
                return false
            }
            return true
        } else if textField == invitationField {
            return true
        }
        return false
    }
    
}
