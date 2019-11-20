//
//  FlowCashBindViewController.swift
//  FBusiness
//
//

import UIKit
import RxSwift
import RxCocoa
import SwiftX
import Toaster

class FlowCashBindViewController: BaseViewController {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var bindButton: UIButton!
    
    private let vmodel = FlowCashBindVModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Theme.decorate(field: nameField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: accountField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        
        Theme.decorate(button: bindButton)
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        view.endEditing(true)
        _bind()
    }
    
}

extension FlowCashBindViewController {
    
    private func _initUI() {
        navigationItemBackStyle = .backGray
        navigationItem.title = "绑定支付宝"
        
        if let alipay = UserVModel.default.currentUser?.alipay {
            nameField.text = alipay.name
            accountField.text = alipay.account
        }
        
        _ = Observable.combineLatest(nameField.rx.text.asObservable(), accountField.rx.text.asObservable()) { (name, account)-> (String, String) in
                return (name ?? "", account ?? "")
            }.takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (element) in
                guard let weakSelf = self else { return }
                weakSelf.bindButton.isEnabled = element.0.count != 0 && element.1.count != 0
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
        if endY != UIScreen.height {
            targetTop = 10
        }
        topConstraint.constant = targetTop
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }

    private func _bind() {
        guard (nameField.text?.count ?? 0)  != 0 else {
            Toast.show("请输入支付宝绑定的真实姓名")
            return
        }
        guard (accountField.text?.count ?? 0) != 0 else {
            Toast.show("请输入支付宝账号")
            return
        }
        startHUDAnimation()
        vmodel.bind(nameField.text!, accountField.text!) { [weak self] (token, error) in
            guard let weakSelf = self else { return }
            self?.stopHUDAnimation()
            if error == nil {
                let currentUser = UserVModel.default.currentUser
                let alipay = UserModel.Alipay()
                alipay.name = weakSelf.nameField.text!
                alipay.account = weakSelf.accountField.text!
                currentUser?.alipay = alipay
                UserVModel.default.currentUser = currentUser
                
                Toast.show("绑定成功")
                topNavigationController?.popViewController(animated: true)
            }
        }
    }
    
}

extension FlowCashBindViewController {
    
    static public func show() {
        let vc = FlowCashBindViewController(nibName: "FlowCashBindViewController", bundle: Bundle.currentMine)
        vc.hidesBottomBarWhenPushed = true
        topNavigationController?.pushViewController(vc, animated: true)
    }
    
}

extension FlowCashBindViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        Theme.decorate(field: nameField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: accountField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: textField, shadowColor: UIColor(hexColor: "#66B30C"), borderColor: UIColor(hexColor: "#66B30C"))
    }
}
