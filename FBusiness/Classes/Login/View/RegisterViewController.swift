//
//  RegisterViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import RxSwift
import RxCocoa
import Toaster

class RegisterViewController: BaseViewController {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var invitationField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var codeButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    private lazy var thirdPartyView: LoginThirdPartyView = {
        let view = LoginThirdPartyView.loadFromXib()
        view.handler = { [weak self] (type) in
            self?._thirdPartyAuth(type)
        }
        return view
    }()
    
    private let registerVModel = RegisterVModel()
    private let loginVModel = LoginVModel()
    private var timerDisposable: Disposable?
    
    var handler: UserVModel.VerifyHandler?

    override public func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardObserver()
        
        _initUI()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = UIDevice.iphone_667_or_less ? LoginThirdPartyView.height - 40 : LoginThirdPartyView.height
        thirdPartyView.frame = CGRect(x: 0, y: view.height - UIScreen.homeIndicatorMoreHeight - height, width: UIScreen.width, height: height)
        
        Theme.decorate(field: phoneField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: codeField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: invitationField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: passwordField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        view.addSubview(thirdPartyView)
        
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

extension RegisterViewController {
    
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
        
        _ = Observable.combineLatest(phoneField.rx.text.asObservable(), codeField.rx.text.asObservable(), passwordField.rx.text) { (phone, code, password) -> (String, String, String) in
                return (phone ?? "", code ?? "", password ?? "")
            }.takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (element) in
                guard let weakSelf = self else { return }
                weakSelf.codeButton.isEnabled = element.0.count == 11
                
                weakSelf.registerButton.isEnabled = element.0.count == 11 && element.1.count == 6 && element.2.count >= 6
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
        if endY != UIScreen.height && (invitationField.isFirstResponder || passwordField.isFirstResponder) {
            topConstraint.constant = 15
        }
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
    
    // 三方认证
    private func _thirdPartyAuth(_ type: LoginThirdPartyView.LoginThirdType) {
        topViewController?.startHUDAnimation()
        switch type {
        case .qq:
            XQQ.default.auth { [weak self] (error, _, jsonResponse) in
                topViewController?.stopHUDAnimation()
                if let json = jsonResponse, let unionid = json["unionid"] as? String {
                    self?._login(way: "qq", userRegId: unionid, json: json)
                } else {
                    Toast.show("QQ授权错误")
                }
            }
        case .wechat:
            XWeChat.default.auth(with: self) { [weak self] (error, _, jsonResponse) in
                topViewController?.stopHUDAnimation()
                if let json = jsonResponse {
                    self?._login(way: "weixin", userRegId: json["unionid"] as! String, json: json)
                } else {
                    Toast.show("微信授权错误")
                }
            }
        default:
            XWeibo.default.auth(with: "http://www.baidu.com") { [weak self] (error, _, jsonResponse) in
                topViewController?.stopHUDAnimation()
                if let json = jsonResponse, let uid = XWeibo.default.uid {
                    self?._login(way: "weibo", userRegId: uid, json: json)
                } else {
                    Toast.show("微博授权错误")
                }
            }
            
        }
    }
    
    // 三方登录
    private func _login(way: String, userRegId: String, json: [AnyHashable: Any]) {
        startHUDAnimation()
        loginVModel.loginWith(way: way, userRegId: userRegId) { [weak self] (token, error) in
            self?.stopHUDAnimation()
            if let error = error {
                if error == HttpError.error402 {
                    let bindVC = BindViewController(nibName: "BindViewController", bundle: Bundle.currentLogin)
                    bindVC.handler = self?.handler
                    bindVC.way = way
                    bindVC.jsonResponse = json
                    self?.navigationController?.pushViewController(bindVC, animated: true)
                }
            } else {
                self?.navigationController?.dismiss(animated: true, completion: {
                    self?.handler?(true)
                })
            }
        }
    }
    
    private func _regist() {
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
        startHUDAnimation()
        registerVModel.regist(phoneField.text!, codeField.text!, passwordField.text!, invitationField.text) { [weak self] (token, error) in
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

extension RegisterViewController: UITextFieldDelegate {
    
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
