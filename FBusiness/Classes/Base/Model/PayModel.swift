//
//  PayModel.swift
//  FBusiness
//
//

public class PayModel: Codable {
    public var orderId: String?

    public var alipay: String?
    public var wxpay: WechatPay?
    public var trustAccount: Bool? = false  // 本地记录使用
}

public extension PayModel {
    
    public class WechatPay: Codable {
        public var package: String = ""
        public var appid: String = ""
        public var sign: String = ""
        public var partnerid: String = ""
        public var prepayid: String = ""
        public var noncestr: String = ""        // 微信返回的随机字符串
        public var timestamp: String = ""
    }
    
}


public extension PayModel {
    
    /// 流水支付类型（wxpay：微信支付、alipay：支付宝、coupon：优惠券、cash：现金、balance：账户余额、trustAccount：账期）
    public enum PayType: String {
        case unknown
        case wxpay
        case alipay
        case coupon
        case cash
        case balance
        case trustAccount
        
        public var description: String {
            switch self {
            case .unknown:
                return "未知"
            case .wxpay:
                return "微信支付"
            case .alipay:
                return "支付宝支付"
            case .coupon:
                return "优惠券支付"
            case .cash:
                return "现金支付"
            case .balance:
                return "余额支付"
            case .trustAccount:
                return "账期支付"
            }
        }
    }
    
}
