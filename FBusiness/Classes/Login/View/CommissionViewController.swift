//
//  CommissionViewController.swift
//  FBusiness
//
//

import UIKit
import RxSwift
import RxCocoa
import SwiftX

class CommissionViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var view0: UIView!
    @IBOutlet weak var view0HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var view0HightlightImgv: UIImageView!
    @IBOutlet weak var text0Label: UILabel!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view1hightlightImgv: UIImageView!
    @IBOutlet weak var text1Label: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    private let vmodel = CouponVModel()
    var handler: UserVModel.VerifyHandler?

    override func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
    }
    
    override func goBack() {
        navigationController?.dismiss(animated: true, completion: { [weak self] () in
            self?.handler?(true)
        })
        navigationController?.popViewController(animated: true)
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        if CommissionVModel.default.currentCommission?.invitedDeductionDiscountConfig == CommissionModel.Config.option.rawValue {
            startHUDAnimation()
            let type = view0HightlightImgv.isHighlighted ? CouponModel.CouponType.deduction : CouponModel.CouponType.discount
            vmodel.getCoupon(type) { [weak self] (error) in
                self?.stopHUDAnimation()
                if error == nil {
                    self?.navigationController?.dismiss(animated: true, completion: {
                        self?.handler?(true)
                    })
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            navigationController?.dismiss(animated: true, completion: { [weak self] () in
                self?.handler?(true)
            })
            navigationController?.popViewController(animated: true)
        }
    }
    
}

extension CommissionViewController {
    
    private func _initUI() {
        navigationItem.title = "优惠券选择"
        navigationItemBackStyle = .closeGray
        
        view0HightlightImgv.image = UIImage(color: UIColor.white)
        view0HightlightImgv.highlightedImage = UIImage(color: UIColor(hexColor: "#66B30C"))
        let view0Gesture = UITapGestureRecognizer(target: self, action: #selector(_gestureAction(_:)))
        view0.addGestureRecognizer(view0Gesture)

        view1hightlightImgv.image = UIImage(color: UIColor.white)
        view1hightlightImgv.highlightedImage = UIImage(color: UIColor(hexColor: "#66B30C"))
        let view1Gesture = UITapGestureRecognizer(target: self, action: #selector(_gestureAction(_:)))
        view1.addGestureRecognizer(view1Gesture)
        
        Theme.decorate(button: confirmButton)
        
        contentHeightConstraint.constant = 205 + 184 * 2
        scrollView.contentSize = CGSize(width: UIScreen.width, height: contentHeightConstraint.constant)
        
        if CommissionVModel.default.currentCommission?.invitedDeductionDiscountConfig == CommissionModel.Config.option.rawValue {
            view0HightlightImgv.isHighlighted = true
        } else {
            view0HightlightImgv.isHighlighted = true
            view1hightlightImgv.isHighlighted = true
        }
        confirmButton.isEnabled = true
       
        if let model = CommissionVModel.default.currentCommission {
            //100#-50
            let money = model.invitedDeductionCoupon.replacingOccurrences(of: "#-", with: "减")
            let text0 = "满减卡（满\(money)元）"
            let attributedText0 = NSMutableAttributedString(string: text0, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
            let range0 = NSRange(location: 0, length: 3)
            attributedText0.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexColor: "#333333"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)], range: range0)
            text0Label.attributedText = attributedText0
            
            let text1 = String(format: "折扣卡（享%.1f折优惠）", model.invitedDiscountCoupon * 10)
            let attributedText1 = NSMutableAttributedString(string: text1, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
            let range1 = NSRange(location: 0, length: 3)
            attributedText1.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexColor: "#333333"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)], range: range1)
            text1Label.attributedText = attributedText1
        }
    }
    
    @objc private func _gestureAction(_ gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.view == view0 {
            view0HightlightImgv.isHighlighted = true
            view1hightlightImgv.isHighlighted = CommissionVModel.default.currentCommission?.invitedDeductionDiscountConfig == CommissionModel.Config.both.rawValue
        } else {
            view1hightlightImgv.isHighlighted = true
            view0HightlightImgv.isHighlighted = CommissionVModel.default.currentCommission?.invitedDeductionDiscountConfig == CommissionModel.Config.both.rawValue
        }
    }
}

extension CommissionViewController {
    
    static public func show(handler: UserVModel.VerifyHandler? = nil) {
        UserVModel.default.verify { (success) in
            if success {
                let vc = CommissionViewController(nibName: "CommissionViewController", bundle: Bundle.currentLogin)
                vc.handler = handler
                vc.hidesBottomBarWhenPushed = true
                topNavigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

