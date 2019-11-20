//
//  HouseKeepingTableViewCell.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class HouseKeepingTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var SNOLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var serviceTimeLabel: UILabel!
    
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var remarkHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var orderTimeLabel: UILabel!
    
    
    @IBOutlet weak var bottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var payWayLabel: UILabel!
    @IBOutlet weak var aresFeeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var funcView: UIView!
    @IBOutlet weak var funcViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var func0Button: UIButton!
    
    @IBOutlet weak var funcButton: UIButton!
    @IBOutlet weak var funcTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var funcWidthConstraint: NSLayoutConstraint!
    
    private var vmodel = HouseKeepingVModel()
    private let payWayView = OrderPayWayView.loadFromXib()
    
    var model: HouseKeepingModel? {
        didSet {
            if let model = model, let addressInfo = model.addressInfo {
                SNOLabel.text = model.orderSNo
                
                let status = HouseKeepingModel.Status(rawValue: model.status) ?? .unpaid
                statusLabel.text = status.description
                
                nameLabel.text = "\(addressInfo.userName)\(addressInfo.sexual == "male" ? "先生" : "女士")    \(addressInfo.userPhone)"
                addressLabel.text = "\(addressInfo.area ?? "")\(addressInfo.userAddress ?? "")"
                
                serviceTimeLabel.text = Date(timeIntervalSince1970: model.serviceTime / 1000).format(to: "yyyy-MM-dd HH:mm")
                var text = ""
                if status == .canceled {
                    text = model.remark?.reason == "" ? "--" : (model.remark?.reason ?? "--")
                } else {
                    text = model.remark?.remark == "" ? "--" : (model.remark?.remark ?? "--")
                }
                remarkLabel.text = text
                orderTimeLabel.text = Date(timeIntervalSince1970: model.orderTime / 1000).format(to: "yyyy-MM-dd HH:mm:ss")
                
                aresFeeLabel.text = "\(model.area ?? (model.remark?.area ?? 0))平米 x \(model.price ?? (model.remark?.price ?? 0))/平米，合计："
                priceLabel.text = String(format: "￥%.2f", model.orderMoney)
                
                let payway = PayModel.PayType(rawValue: model.payWay ?? "") ?? .unknown
                
                payWayLabel.text = nil
                funcTrailingConstraint.constant = 15
                funcWidthConstraint.constant = 71
                switch status {
                case .unpaid:
                    func0Button.setTitle("取消订单", for: .normal)
                    funcButton.setTitle("立即支付", for: .normal)
                case .paid:
                    payWayLabel.text = payway.description
                    func0Button.setTitle("取消订单", for: .normal)
                    funcButton.isHidden = true
                    funcTrailingConstraint.constant = 0
                    funcWidthConstraint.constant = 0
                case .recived:
                    payWayLabel.text = payway.description
                    func0Button.setTitle("取消订单", for: .normal)
                    funcButton.isHidden = true
                    funcTrailingConstraint.constant = 0
                    funcWidthConstraint.constant = 0
                case .finished, .canceled:
                    if status == .finished {
                        payWayLabel.text = payway.description
                    }
                    bottomHeightConstraint.constant = 40
                    funcView.isHidden = true
                    funcViewHeightConstraint.constant = 0
                }
                
            }
        }
    }
    private var products = [ProductModel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        Theme.decorate(button: func0Button, font: UIFont.systemFont(ofSize: 12), color: UIColor(hexColor: "#ED9E32"), cornerRadius: 13)
        Theme.decorate(button: funcButton, font: UIFont.systemFont(ofSize: 12), color: UIColor(hexColor: "#66B30C"), cornerRadius: 13)

        payWayView.dismiss()
        payWayView.enableTrustAccount = false
        payWayView.handler = { [weak self] (type) in
            guard let weakSelf = self, let orderId = weakSelf.model?.orderId else { return }
            topViewController?.startHUDAnimation()
            weakSelf.vmodel.pay(orderId, type, { (payModel, error) in
                topViewController?.stopHUDAnimation()
                if let model = payModel {
                    PayVModel.default.pay(with: type, model: model, isOrder: false, topNavigationController: nil, completion: nil)
                }
            })
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        guard let model = self.model else { return }
        if sender.tag == 0 {
            let alertController = UIAlertController(title: "温馨提示", message: "确定要取消该家政服务？", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { [weak self] (_) in
                self?._cancel()
            }))
            topViewController?.present(alertController, animated: true, completion: nil)
        } else {
            payWayView.show(with: model.orderMoney)
        }
    }
    
}

extension HouseKeepingTableViewCell {
    
    private func _cancel() {
        guard let orderId = self.model?.orderId else { return }
        topViewController?.startHUDAnimation()
        vmodel.cancel(orderId) { (baseModel, error) in
            topViewController?.stopHUDAnimation()
            if error == nil {
                NotificationCenter.default.post(name: Constants.notification_order_house_canceled, object: nil)
            }
        }
    }
    
}

extension HouseKeepingTableViewCell {
    
    static func calculateHeight(_ model: HouseKeepingModel) -> CGFloat {
        let type = HouseKeepingModel.Status(rawValue: model.status) ?? .paid
        return 273 - ((type == .finished || type == .canceled) ? 40 : 0)
    }
    
}
