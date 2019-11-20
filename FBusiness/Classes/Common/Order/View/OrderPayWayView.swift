//
//  OrderPayWayView.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster
import RxSwift
import RxCocoa

class OrderPayWayView: UIView {
    
    typealias PayHandler = ((_ type: PayModel.PayType) -> Void)

    @IBOutlet weak var opacityView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var centainView: UIView!
    @IBOutlet weak var certainBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var certainButton: UIButton!
    
    @IBOutlet weak var alipayView: UIView!
    @IBOutlet weak var alipayHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alipayCheckView: UIImageView!
    
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var moreArrowImgv: UIImageView!
    
    @IBOutlet weak var wechatView: UIView!
    @IBOutlet weak var wechatCheckView: UIImageView!
    

    @IBOutlet weak var trustAccountView: UIView!
    @IBOutlet weak var trustAccountCheckView: UIImageView!
    @IBOutlet weak var trustAccountLabel: UILabel!
    @IBOutlet weak var trustHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var priceLabel: UILabel!
    private var payWay: BehaviorRelay<PayModel.PayType> = BehaviorRelay<PayModel.PayType>(value: .wxpay)
    private var isExpanded: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    private var contentViewHeight: CGFloat {
        return 350 + alipayHeightConstraint.constant + UIScreen.homeIndicatorMoreHeight + trustHeightConstraint.constant
    }
    var enableTrustAccount: Bool = true {
        didSet {
            trustHeightConstraint.constant = enableTrustAccount && UserVModel.default.currentUser?.userType == UserModel.UserType.shop.rawValue ? 70 : 0
            trustAccountView.isHidden = trustHeightConstraint.constant == 0
        }
    }
    private var totalPrice: Float = 0
    
    var handler: PayHandler?
    
    
    class func loadFromXib() -> OrderPayWayView {
        if let view = Bundle.currentCommon.loadNibNamed("OrderPayWayView", owner: self, options: nil)?.first as? OrderPayWayView {
            view.frame = UIScreen.main.bounds
            view.contentBottomConstraint.constant = -view.contentViewHeight
            return view
        }
        return OrderPayWayView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        opacityView.alpha = 0.01
        
        alipayHeightConstraint.constant = isExpanded.value ? 70 : 0
        alipayView.isHidden = !isExpanded.value
        
        enableTrustAccount = UserVModel.default.currentUser?.userType == UserModel.UserType.shop.rawValue

        certainBottomConstraint.constant = UIScreen.homeIndicatorMoreHeight
        
        contentHeightConstraint.constant = contentViewHeight
        contentBottomConstraint.constant = -contentViewHeight

        Theme.decorate(button: certainButton, cornerRadius: 0)
        
        let alipayGesture = UITapGestureRecognizer(target: self, action: nil)
        alipayView.addGestureRecognizer(alipayGesture)
        _ = alipayGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.payWay.accept(.alipay)
            })
        
        let moreGesture = UITapGestureRecognizer(target: self, action: nil)
        moreView.addGestureRecognizer(moreGesture)
        _ = moreGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                guard let weakSelf = self else { return }
                weakSelf.isExpanded.accept(!weakSelf.isExpanded.value)
            })
        
        let trustGesture = UITapGestureRecognizer(target: self, action: nil)
        trustAccountView.addGestureRecognizer(trustGesture)
        _ = trustGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                let maxBanlace = UserVModel.default.currentUser?.config?.trustAccount?.maxBanlance ?? 0
                let usedBanlace = UserVModel.default.currentUser?.config?.trustAccount?.usedBanlace ?? 0
                guard let weakSelf = self, maxBanlace - usedBanlace > weakSelf.totalPrice else {
                    Toast.show("可用账期金额小于商品价格")
                    return
                }
                weakSelf.payWay.accept(.trustAccount)
            })

        let wxpayGesture = UITapGestureRecognizer(target: self, action: nil)
        wechatView.addGestureRecognizer(wxpayGesture)
        _ = wxpayGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.payWay.accept(.wxpay)
            })
        
        _ = payWay.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (type) in
                guard let weakSelf = self else { return }
                weakSelf.trustAccountCheckView.isHidden = type != .trustAccount
                weakSelf.alipayCheckView.isHidden = type != .alipay
                weakSelf.wechatCheckView.isHidden = type != .wxpay
            })
        
        _ = isExpanded.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (expanded) in
                guard let weakSelf = self else { return }
                weakSelf.moreArrowImgv.image = UIImage(named: expanded ? "icon_arrow_green_stroke_up" : "icon_arrow_green_stroke_down", in: Bundle.currentBase, compatibleWith: nil)
                weakSelf.alipayHeightConstraint.constant = weakSelf.isExpanded.value ? 70 : 0
                weakSelf.alipayView.isHidden = !weakSelf.isExpanded.value
                weakSelf.contentHeightConstraint.constant = weakSelf.contentViewHeight
                UIView.animate(withDuration: 0.25, animations: {
                    weakSelf.setNeedsLayout()
                })
            })
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        _dismiss()
        if sender.tag == 1 {
            handler?(payWay.value)
        }
    }
}

extension OrderPayWayView {
    
    private func _show() {
        self.frame = topViewController?.view.bounds ?? UIScreen.main.bounds
        topViewController?.view.addSubview(self)
        opacityView.alpha = 0.01
        contentBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.opacityView.alpha = 0.7
            self.layoutIfNeeded()
        }
    }
    
    private func _dismiss(_ agreed: Bool = false) {
        contentBottomConstraint.constant = -contentViewHeight
        UIView.animate(withDuration: 0.25, animations: {
            self.opacityView.alpha = 0.01
            self.layoutIfNeeded()
        }) { (finish) in
            self.isExpanded.accept(false)
            self.payWay.accept(.wxpay)
            self.removeFromSuperview()
        }
    }
    
}

extension OrderPayWayView {
    
    // trustAccount = false标识即使有账期支付也要关闭掉
    func show(with totalPrice: Float) {
        let maxBanlace = UserVModel.default.currentUser?.config?.trustAccount?.maxBanlance ?? 0
        let usedBanlace = UserVModel.default.currentUser?.config?.trustAccount?.usedBanlace ?? 0
        trustAccountLabel.text = String(format: "可用账期金额%.2f元（\(Float(maxBanlace - usedBanlace) > totalPrice ? "可用" : "不可用")）", Float(maxBanlace - usedBanlace), totalPrice)
        trustAccountView.backgroundColor = Float(maxBanlace - usedBanlace) > totalPrice ? UIColor.white : UIColor(hexColor: "#f7f7f7")
        
        priceLabel.text = String(format: "￥ %.2f", totalPrice)
        self.totalPrice = totalPrice
        
        _show()
    }
    
    func dismiss() {
        _dismiss()
    }

}
