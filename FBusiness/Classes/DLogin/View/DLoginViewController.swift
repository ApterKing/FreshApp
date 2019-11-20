//
//  DLoginViewController.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/25.
//

import UIKit
import SwiftX
import Toaster
import RxSwift
import RxCocoa

public class DLoginViewController: BaseViewController {
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var codeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    private let vmodel = DLoginVModel()
    private var timerDisposable: Disposable?
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardObserver()
        
        _initUI()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Theme.decorate(field: phoneField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: codeField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        
        Theme.decorate(button: loginButton)
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        view.endEditing(true)
        if sender.tag == 0 {
            _getCheckCode()
        } else {
            _login()
        }
    }
    
}

extension DLoginViewController {
    
    private func _initUI() {
        navigationItemBackStyle = .none
        isNavigationBarShadowImageHidden = true
        navigationItem.title = "登录"

        let options: [UIControlStateOption] = [.title("注册", UIColor(hexColor: "#66B30C"), .normal),
                                               .title("注册", UIColor(hexColor: "#a0a0a5"), .disabled),
                                               .title("注册", UIColor(hexColor: "#66B30C").withAlphaComponent(0.7), .highlighted)
        ]
        navigationItem.rightBarButtonItem = customBarButtonItem(options: options, size: CGSize(width: 60, height: 44), isBackItem: false, left: false, handler: { [weak self] (_) in
            let registerVC = DRegisterViewController(nibName: "DRegisterViewController", bundle: Bundle.currentDLogin)
            self?.navigationController?.pushViewController(registerVC, animated: true)
        })
        
        _ = Observable.combineLatest(phoneField.rx.value.asObservable(), codeField.rx.value.asObservable()) { (phone, code) -> (String, String) in
                return (phone ?? "", code ?? "")
            }.takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (element) in
                guard let weakSelf = self else { return }
                weakSelf.codeButton.isEnabled = element.0.count == 11
                weakSelf.loginButton.isEnabled = (element.0.count == 11) && (element.1.count == 6)
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
        
        topConstraint.constant = 90
        if endY != UIScreen.height {
            topConstraint.constant = 50
        }
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func _getCheckCode() {
        guard let phone = phoneField.text else { return }
        startHUDAnimation()
        vmodel.checkCode(phone) { [weak self] (model, error) in
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
    
    private func _login() {
        guard phoneField.text?.count ?? 0  == 11 else {
            Toast.message("请输入11位手机号码")
            return
        }
        guard codeField.text?.count ?? 0  == 6 else {
            Toast.message("请输入6位验证码")
            return
        }
        startHUDAnimation()
        vmodel.loginWith(phone: phoneField.text!, code: codeField.text!) { [weak self] (token, error) in
            self?.stopHUDAnimation()
            if error == nil {
                UIApplication.shared.keyWindow?.rootViewController = XBaseNavigationController(rootViewController: DHomeViewController())
            }
        }
    }
    
}

extension DLoginViewController: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == phoneField {
            textField.keyboardType = .phonePad
        } else {
            textField.keyboardType = .numberPad
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        Theme.decorate(field: phoneField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: codeField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: textField, shadowColor: UIColor(hexColor: "#66B30C"), borderColor: UIColor(hexColor: "#66B30C"))
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var targetStr = NSString(string: textField.attributedText?.string ?? "").replacingCharacters(in: range, with: string)
        
        if textField == phoneField {
            let phone = targetStr.trimmingCharacters(in: CharacterSet.whitespaces)
            if phone.count > 11 {
                let targetIndex = targetStr.index(targetStr.startIndex, offsetBy: 11)
                targetStr = String(targetStr.prefix(upTo: targetIndex))
                textField.text = targetStr
                return false
            }
            return true
        } else if textField == codeField {
            let code = targetStr.trimmingCharacters(in: CharacterSet.whitespaces)
            if code.count > 6 {
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
