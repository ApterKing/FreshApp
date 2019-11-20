//
//  CarBottomView.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster

class CarBottomView: UIView {

    @IBOutlet weak var chooseView: UIView!
    @IBOutlet weak var chooseAllImageView: UIImageView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var button: UIButton!

    private let vmodel = OrderTimeVModel()
    private var timeModel: DeliveryTimeModel? {
        didSet {
            _updateDeliveryPrice()
        }
    }
    
    var isSettlement: Bool = true {
        didSet {
            priceView.isHidden = !isSettlement
            if isSettlement {
                button.setTitle("结算", for: .normal)
                button.setBackgroundImage(UIImage(color: UIColor(hexColor: "#66B30C") ), for: .normal)
                button.setBackgroundImage(UIImage(color: UIColor(hexColor: "#66B30C").withAlphaComponent(0.9) ), for: .highlighted)
            } else {
                button.setTitle("删除", for: .normal)
                button.setBackgroundImage(UIImage(color: UIColor.red), for: .normal)
                button.setBackgroundImage(UIImage(color: UIColor.red.withAlphaComponent(0.9)), for: .highlighted)
            }
        }
    }
    
    var isCheckedAll: Bool = false {
        didSet {
            chooseAllImageView.image = UIImage(named: isCheckedAll ? "icon_checked" : "icon_uncheck", in: Bundle.currentBase, compatibleWith: nil)
        }
    }
    
    var price: Float = 0 {
        didSet {
            priceLabel.text = String(format: "￥ %.2f", price)
            _updateDeliveryPrice()
        }
    }
    
    class func loadFromXib() -> CarBottomView {
        
        if let view = Bundle.currentCar.loadNibNamed("CarBottomView", owner: self, options: nil)?.first as? CarBottomView {
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: 45)
            return view
        }
        return CarBottomView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isSettlement = true
        isCheckedAll = false
        price = 0

        deliveryLabel.adjustsFontSizeToFitWidth = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(_gestureAction(_:)))
        chooseView.addGestureRecognizer(gesture)
    }
    
    @objc private func _gestureAction(_ gestureRecognizer: UIGestureRecognizer) {
        let models = CarVModel.default.datas.value
        for model in models {
            if CategoryVModel.default.shouldShowSuspendSalePrompt(levelOne: model.pCatelogId) {
                model.isChecked = false
            } else if isSettlement {
                if model.productStatus ?? .normal == .normal && model.stock ?? 0 != 0 {
                    model.isChecked = !isCheckedAll
                } else {
                    model.isChecked = false
                }
            } else {
                model.isChecked = !isCheckedAll
            }
        }
        CarVModel.default.datas.accept(models)
    }

    private func _updateDeliveryPrice() {
        guard let model = timeModel else {
            deliveryLabel.text = nil
            return
        }
        if price >= 0 && price < (model.deliverFreeOrderMoney ?? 0) && CarVModel.default.checkedCount() != 0 {
            deliveryLabel.text = String(format: "差￥%.2f\n可免配送费", (model.deliverFreeOrderMoney ?? 0) - price)
        } else {
            if CarVModel.default.checkedCount() != 0 {
                deliveryLabel.text = "免配送费"
            } else {
                deliveryLabel.text = nil
            }
        }
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        // 得到当前选择的数据
        UserVModel.default.verify { [weak self] (success) in
            guard let weakSelf = self else { return }
            if success {
                let selectedModels = CarVModel.default.datas.value.filter { (model) -> Bool in
                    return model.isChecked ?? false
                }
                guard selectedModels.count != 0 else {
                    Toast.show("请先选择商品")
                    return
                }
                if weakSelf.isSettlement {
                    // 选择地址
                    guard AddressVModel.default.currentAddress != nil else {
                        Toast.show("请添加收货地址")
                        return
                    }

                    // 判定是否显示提示
                    if let deliverFreeOrderMoney = weakSelf.timeModel?.deliverFreeOrderMoney, weakSelf.price >= 0 && weakSelf.price < deliverFreeOrderMoney {
                        let alertController = UIAlertController(title: "温馨提示", message: String(format: "当前订单再买￥%.2f元，可以减免%.f元配送费，是否确认下单？", deliverFreeOrderMoney - weakSelf.price, weakSelf.timeModel?.deliveryMoney ?? 0), preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "再买点", style: .cancel, handler: nil))
                        alertController.addAction(UIAlertAction(title: "下单", style: .destructive, handler: { (_) in
                            OrderSubmitViewController.show()
                        }))
                        topViewController?.present(alertController, animated: true, completion: nil)
                    } else {
                        OrderSubmitViewController.show()
                    }
                } else {
                    let cartIds = selectedModels.map { (model) -> String in
                        return model.cartId
                    }
                    topViewController?.startHUDAnimation()
                    CarVModel.default.delete(cartIds, false) { (baseModel, error) in
                        CarVModel.default.fetch({ (_) in
                            topViewController?.stopHUDAnimation()
                        })
                    }
                }
            }
        }
    }
}

extension CarBottomView {

    func refreshDeliveryTime() {
        vmodel.fetch { [weak self] (error) in
            guard let weakSelf = self else { return }

            let enableTomorrowTimes = weakSelf.vmodel.tomorrowTimes.filter({ (model) -> Bool in
                return model.enable == "yes"
            })
            if enableTomorrowTimes.count != 0 {
                weakSelf.timeModel = enableTomorrowTimes[0]
            } else {
                let enableAfterTomorrowTimes = weakSelf.vmodel.afterTomorrowTimes.filter({ (model) -> Bool in
                    return model.enable == "yes"
                })
                if enableAfterTomorrowTimes.count != 0 {
                    weakSelf.timeModel = enableAfterTomorrowTimes[0]
                }
            }
        }
    }

}
