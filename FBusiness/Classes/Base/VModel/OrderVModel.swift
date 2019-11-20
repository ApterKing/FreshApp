//
//  OrderVModel.swift
//  FBusiness
//
//


public class OrderVModel: BaseVModel {
    
    // 从购物车提交订单（账期支付返回的数据格式不一样）
    public func add(_ params: [AnyHashable: Any], _ payType: PayModel.PayType, _ complection: ((_ model: PayModel?, _ error: HttpError?) -> Void)?) {
        cancel()
        switch payType {
        case .trustAccount:
            post(BaseModel.self, URLPath.Order.add, params) { (baseModel, error) in
                if error == nil {
                    let payModel = PayModel()
                    payModel.trustAccount = true
                    complection?(payModel, nil)
                } else {
                    complection?(nil, error)
                }
            }
        default:
            post(PayModel.self, URLPath.Order.add, params) { (payModel, error) in
                complection?(payModel, error)
            }
        }
    }
    
    public func cancel(_ orderId: String, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)?) {
        let params = [
            "orderId": orderId,
            "reason": "用户主动取消"
        ]
        cancel()
        post(BaseModel.self, URLPath.Order.cancel, params) { (data, error) in
            complection?(data, error)
        }
    }
    
    // 支付待支付的订单
    public func pay(_ orderId: String, _ payType: PayModel.PayType, _ complection: ((_ model: PayModel?, _ error: HttpError?) -> Void)?) {
        let params = [
            "orderId": orderId,
            "payWay": payType.rawValue
        ]
        cancel()
        switch payType {
        case .trustAccount:
            post(BaseModel.self, URLPath.Order.pay, params) { (baseModel, error) in
                if error == nil {
                    let payModel = PayModel()
                    payModel.trustAccount = true
                    complection?(payModel, nil)
                } else {
                    complection?(nil, error)
                }
            }
        default:
            post(PayModel.self, URLPath.Order.pay, params) { (payModel, error) in
                payModel?.orderId = orderId
                complection?(payModel, error)
            }
        }
    }

    public func done(_ orderId: String?) {
        guard let orderId = orderId else { return }
        let params = [
            "orderId": orderId
        ]
        post(BaseModel.self, URLPath.Order.done, params) { (baseModel, error) in
            #if DEBUG
            print("orderDone  --- \(String(describing: baseModel))   \(String(describing: error))")
            #endif
        }
    }
    
}
