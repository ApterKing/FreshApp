//
//  PayVModel.swift
//  FBusiness
//
//

import SwiftX

public class PayVModel: NSObject {
    
    public static let `default` = PayVModel()
    private lazy var orderVModel: OrderVModel = {
        let vmodel = OrderVModel()
        return vmodel
    }()
    
    // 如果  isOrder == true 标识支付订单，否则支付的是家政服务 topNavigationController != nil 表示需要关闭前一个页面
    #if FRESH_CLIENT
    func pay(with way: PayModel.PayType, model: PayModel, isOrder: Bool = true, topNavigationController: UINavigationController? = nil, completion: ((_ success: Bool) -> Void)? = nil) {
        if way == .alipay {
            if let alipay = model.alipay {  // 如果返回需要支付
                XAlipay.default.pay(with: alipay, scheme: "freshClientAlipay", payHandler: { (error) in
                    if let error = error as NSError? {
                        OrderPayResultViewController.show(with: .failure(error.localizedDescription), isOrder: isOrder, navigationController: topNavigationController)
                        completion?(false)
                    } else {
                        OrderPayResultViewController.show(with: .success(), isOrder: isOrder, navigationController: topNavigationController)
                        CarVModel.default.fetch(nil)
                        PayVModel.default.orderVModel.done(model.orderId)
                        NotificationCenter.default.post(name: Constants.notification_pay_success, object: nil)
                        NotificationCenter.default.post(name: Constants.notification_pay_house_success, object: nil)
                        completion?(true)
                    }
                })
            } else {  // 否则直接表示支付成功
                OrderPayResultViewController.show(with: .success(), isOrder: isOrder, navigationController: topNavigationController)
                CarVModel.default.fetch(nil)
                PayVModel.default.orderVModel.done(model.orderId)
                NotificationCenter.default.post(name: Constants.notification_pay_success, object: nil)
                NotificationCenter.default.post(name: Constants.notification_pay_house_success, object: nil)
                completion?(true)
            }
        } else if way == .wxpay {
            if let wxpay = model.wxpay, let data = try? JSONEncoder.encode(wxpay), let params = (try? JSONSerialization.object(with: data)) as? [AnyHashable: Any] {  // 调用微信
                XWeChat.default.pay(with: params, payHandler: { (error) in
                    print("XWechat 支付    \(String(describing: error))")
                    if let error = error as NSError? {
                        OrderPayResultViewController.show(with: .failure(error.localizedDescription), isOrder: isOrder, navigationController: topNavigationController)
                        completion?(false)
                    } else {
                        OrderPayResultViewController.show(with: .success(), isOrder: isOrder, navigationController: topNavigationController)
                        CarVModel.default.fetch(nil)
                        PayVModel.default.orderVModel.done(model.orderId)
                        NotificationCenter.default.post(name: Constants.notification_pay_success, object: nil)
                        NotificationCenter.default.post(name: Constants.notification_pay_house_success, object: nil)
                        completion?(true)
                    }
                })
            } else {
                OrderPayResultViewController.show(with: .success(), isOrder: isOrder, navigationController: topNavigationController)
                CarVModel.default.fetch(nil)
                PayVModel.default.orderVModel.done(model.orderId)
                NotificationCenter.default.post(name: Constants.notification_pay_success, object: nil)
                NotificationCenter.default.post(name: Constants.notification_pay_house_success, object: nil)
                completion?(true)
            }
        } else {
            if model.trustAccount ?? false == false {
                OrderPayResultViewController.show(with: .failure("账期支付失败"), isOrder: isOrder, navigationController: topNavigationController)
                completion?(false)
            } else {
                OrderPayResultViewController.show(with: .success(), isOrder: isOrder, navigationController: topNavigationController)
                CarVModel.default.fetch(nil)
                NotificationCenter.default.post(name: Constants.notification_pay_success, object: nil)
                NotificationCenter.default.post(name: Constants.notification_pay_house_success, object: nil)
                completion?(true)
                
                UserVModel.default.userInfo(nil)
            }
        }
    }
    #endif

}
