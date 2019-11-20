//
//  InputCodeViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import RxCocoa
import RxSwift
import Toaster

class InputCodeViewController: BaseViewController {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var button: UIButton!

    private let vmodel = InviteCodeVModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardObserver()

        _initUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        Theme.decorate(field: codeField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(button: button)
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        view.endEditing(true)
        _bind()
    }

}

extension InputCodeViewController {

    private func _initUI() {
        navigationItemBackStyle = .backGray
        navigationItem.title = "填写邀请码"

        if let from1UserCode = UserVModel.default.currentUser?.from1UserCode {
            codeField.text = from1UserCode
            codeField.isEnabled = false
            button.setTitle("已填写", for: .normal)
        }

        _ = codeField.rx.text
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (text) in
                guard let weakSelf = self, let text = text else { return }
                weakSelf.button.isEnabled = text.count != 0 && UserVModel.default.currentUser?.from1UserCode == nil
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
        guard (codeField.text?.count ?? 0)  != 0 else {
            Toast.show("请输入填写邀请码")
            return
        }
        startHUDAnimation()
        vmodel.bind(codeField.text!) { [weak self] (token, error) in
            guard let weakSelf = self else { return }
            self?.stopHUDAnimation()
            if error == nil {
                let currentUser = UserVModel.default.currentUser
                currentUser?.from1UserCode = weakSelf.codeField.text!
                UserVModel.default.currentUser = currentUser
                weakSelf.codeField.isUserInteractionEnabled = false
                weakSelf.button.setTitle("已填写", for: .normal)
                weakSelf.button.isEnabled = false

                if CommissionVModel.default.currentCommission?.invitedDeductionDiscountConfig != CommissionModel.Config.none.rawValue && weakSelf.codeField.text != "" {
                    CommissionViewController.show(handler: nil)
                } else {
                    topNavigationController?.popViewController(animated: true)
                }
            }
        }
    }

}

extension InputCodeViewController {

    static public func show() {
        UserVModel.default.verify { (success) in
            if success {
                let vc = InputCodeViewController(nibName: "InputCodeViewController", bundle: Bundle.currentMine)
                vc.hidesBottomBarWhenPushed = true
                topNavigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}

extension InputCodeViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        Theme.decorate(field: codeField, shadowColor: UIColor.lightGray, borderColor: UIColor.clear)
        Theme.decorate(field: textField, shadowColor: UIColor(hexColor: "#66B30C"), borderColor: UIColor(hexColor: "#66B30C"))
    }
}

