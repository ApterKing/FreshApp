//
//  DHomeTableViewCell.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/26.
//

import UIKit
import Toaster
import SwiftX

class DHomeTableViewCell: UITableViewCell {
    
    static let height: CGFloat = 260
    
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var SNoLabel: UILabel!
    
    @IBOutlet weak var phoneView: UIView!
    
    @IBOutlet weak var redButton: UIButton!
    
    private let vmodel = DHomeVModel()
    
    var model: OrderDetailModel? {
        didSet {
            guard let model = self.model, let order = model.order, let addressInfo = model.addressInfo else { return }
            
            let deliveryStartTime = Date(timeIntervalSince1970: order.deliveryStartTime / 1000).format(to: "MM月dd日 HH:mm")
            let deliveryEndTime = Date(timeIntervalSince1970: order.deliveryEndTime / 1000).format(to: "HH:mm")
            timeLabel.text = "\(deliveryStartTime)-\(deliveryEndTime)"
            
            fromLabel.text = order.stationAddress
            toLabel.text = "\(addressInfo.area ?? "")\(addressInfo.userAddress ?? "")"
            
            nameLabel.text = addressInfo.userName
            SNoLabel.text = order.orderSNo
        }
    }
    
    private lazy var finishInputView: DHomeFinishInputView = {
        let inputView = DHomeFinishInputView.loadFromXib()
        inputView.handler = { [weak self] (code) in
            self?._finishOrder(code)
        }
        return inputView
    }()
    var status: OrderModel.Status = .unpaid {
        didSet {
            if status == .delivering {
                finishInputView.dismiss()
            } else {
                phoneView.isHidden = true
                redButton.setTitle("取货", for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cornerView.round(byRoundingCorners: UIRectCorner(rawValue: UIRectCorner.topRight.rawValue | UIRectCorner.bottomRight.rawValue), cornerRadi: 5)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(_gestureAction(_:)))
        phoneView.addGestureRecognizer(gesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func _gestureAction(_ gestureRecognizer: UIGestureRecognizer) {
        guard let addressInfo = self.model?.addressInfo, let url = URL(string: "telprompt://\(addressInfo.userPhone)") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        guard let model = self.model, let addressInfo = self.model?.addressInfo,  let order = self.model?.order else {
            return
        }
        if sender.tag == 0 {
            // 调用百度导航
            XLocationManager.default.startUpdatingLocation { [weak self] (info, error) in
                if let location = info?.location {
                    var toCoordinate: CLLocationCoordinate2D?
                    if let latitudeString = self?.model?.addressInfo?.latitude, let longitudeString = self?.model?.addressInfo?.longitude, let latitude = Double(latitudeString), let longitude = Double(longitudeString)  {
                        toCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    }
                    
                    guard let to = toCoordinate else {
                        return
                    }
                    let option = BMKOpenWalkingRouteOption()
                    option.appScheme = "baidumapsdk://mapsdk.baidu.com"
                    option.isSupportWeb = true
                    
                    let start = BMKPlanNode()
                    start.pt = location.coordinate
                    start.name = "我的位置"
                    option.startPoint = start
                    let end = BMKPlanNode()
                    end.pt = to
                    end.name = "\(self?.model?.addressInfo?.area ?? "")\(self?.model?.addressInfo?.userAddress ?? "")"
                    option.endPoint = end
                    
                    let ret = BMKOpenRoute.openBaiduMapWalkingRoute(option)
                    if ret != BMK_OPEN_NO_ERROR {
                        Toast.message("开启百度导航失败")
                    }
                } else {
                    Toast.message("获取定位失败")
                }
            }
        } else if sender.tag == 1 {
            DHomeDetailViewController.show(with: model)
        } else {
            if status == .delivering {
                _finishOrder("000000")
//                finishInputView.show(with: order.orderSNo)
            } else {
                _take()
            }
        }
    }
    
}

extension DHomeTableViewCell {
    // 完成配送
    private func _finishOrder(_ code: String) {
        guard let order = model?.order else { return }
        currentViewController?.startHUDAnimation()
        vmodel.finish(orderId: order.orderId, checkCode: code, { [weak self] (data, error) in
            currentViewController?.stopHUDAnimation()
            if let data = data {
                Toast.message(data.msg ?? "送货成功")
                self?.finishInputView.dismiss()
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "order_finish_success"), object: order.orderId)
            }
        })
    }
    
    // 取货
    private func _take() {
        guard let order = model?.order else { return }
        currentViewController?.startHUDAnimation()
        vmodel.take(orderId: order.orderId) { (data, error) in
            currentViewController?.stopHUDAnimation()
            if let model = data {
                Toast.message(model.msg ?? "取货成功")
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "order_take_success"), object: order.orderId)
            }
        }
    }
}
