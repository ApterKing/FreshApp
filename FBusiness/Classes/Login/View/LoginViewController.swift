//
//  LoginViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import RxSwift
import RxCocoa
import Toaster

public class LoginViewController: BaseViewController {
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    private lazy var thirdPartyView: LoginThirdPartyView = {
        let view = LoginThirdPartyView.loadFromXib()
        view.handler = { [weak self] (type) in
            self?._thirdPartyAuth(type)
        }
        return view
    }()
    
    private var handler: UserVModel.VerifyHandler?
    private let vmodel = LoginVModel()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardObserver()
        
        _initUI()
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        view.endEditing(true)
        if sender.tag == 0 { // 忘记密码
            let forgetVC = ForgetViewController(nibName: "ForgetViewController", bundle: Bundle.currentLogin)
            self.navigationController?.pushViewController(forgetVC, animated: true)
        } else {
            _login()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        thirdPartyView.frame = CGRect(x: 0, y: view.height - UIScreen.homeIndicatorMoreHeight - LoginThirdPartyView.height, width: UIScreen.width, height: LoginThirdPartyView.height)
        
        Theme.decorate(field: phoneField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: passwordField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        view.addSubview(thirdPartyView)
        
        Theme.decorate(button: loginButton)
    }
    
}

public extension LoginViewController {
    
    static public func show(_ handler: UserVModel.VerifyHandler? = nil) {
        guard !UserVModel.default.isLogined else { return }
        let currentVC = topViewController
        guard !(currentVC is LoginViewController) && !(currentVC is RegisterViewController) && !(currentVC is ForgetViewController) && !(currentVC is BindViewController) else { return }
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: Bundle.currentLogin)
        loginVC.handler = handler
        topViewController?.present(XBaseNavigationController(rootViewController: loginVC), animated: true, completion: {
            
        })
    }
    
}

extension LoginViewController {
    
    private func _initUI() {
        navigationItemBackStyle = .closeGray
        isNavigationBarShadowImageHidden = true
        navigationItem.title = "登录"
        
        let options: [UIControlStateOption] = [.title("注册", UIColor(hexColor: "#66B30C"), .normal),
                       .title("注册", UIColor(hexColor: "#a0a0a5"), .disabled),
                       .title("注册", UIColor(hexColor: "#66B30C").withAlphaComponent(0.7), .highlighted)
                    ]
        navigationItem.rightBarButtonItem = customBarButtonItem(options: options, size: CGSize(width: 60, height: 44), isBackItem: false, left: false, handler: { [weak self] (_) in
                let registerVC = RegisterViewController(nibName: "RegisterViewController", bundle: Bundle.currentLogin)
                self?.navigationController?.pushViewController(registerVC, animated: true)
            })

        _ = Observable.combineLatest(phoneField.rx.text.asObservable(), passwordField.rx.text) { (phone, password) -> (String, String) in
            return (phone ?? "", password ?? "")
            }.takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (element) in
                guard let weakSelf = self else { return }
                weakSelf.loginButton.isEnabled = element.0.count == 11 && element.1.count != 0
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
        
        var targetTop: CGFloat = 100
        if endY != UIScreen.height {
            targetTop = 80
        }
        topConstraint.constant = targetTop
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
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
        vmodel.loginWith(way: way, userRegId: userRegId) { [weak self] (token, error) in
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
                self?.navigationController?.dismiss(animated: true, completion: nil)
                self?.handler?(true)
            }
        }
    }
    
    private func _login() {
        let passwordCount = passwordField.text?.count ?? 0
        guard phoneField.text?.count ?? 0  == 11 else {
            Toast.show("请输入11位手机号码")
            return
        }
        guard passwordCount >= 6, passwordCount <= 18 else {
            Toast.show("密码需 6 ~ 18 位")
            return
        }
        startHUDAnimation()
        vmodel.loginWith(phone: phoneField.text!, password: passwordField.text!) { [weak self] (token, error) in
            self?.stopHUDAnimation()
            if let error = error {
                Toast.show(error.localizedDescription)
            } else {
                self?.navigationController?.dismiss(animated: true, completion: {
                    self?.handler?(true)
                })
            }
        }
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == phoneField {
            textField.keyboardType = .numberPad
        } else {
            textField.keyboardType = .asciiCapable
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        Theme.decorate(field: phoneField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: passwordField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: textField, shadowColor: UIColor(hexColor: "#66B30C"), borderColor: UIColor(hexColor: "#66B30C"))
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
        } else if textField == passwordField {
            let text = targetStr.trimmingCharacters(in: CharacterSet.whitespaces)
            if text.count > 18 {
                let targetIndex = targetStr.index(targetStr.startIndex, offsetBy: 18)
                targetStr = String(targetStr.prefix(upTo: targetIndex))
                textField.text = targetStr
                return false
            }
            return true
        }
        return false
    }
    
}
