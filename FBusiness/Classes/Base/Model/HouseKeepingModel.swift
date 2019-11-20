//
//  HouseKeepingModel.swift
//  FBusiness
//
//

public class HouseKeepingModel: Codable {
    
    public var orderId: String = ""
    public var orderSNo: String = ""        // 订单号
    public var serviceTime: TimeInterval = 0        // 预约时间
    public var orderTime: TimeInterval = 0      // 订单时间
    public var orderMoney: Float = 0
    public var status: String = Status.unpaid.rawValue
    
    public var area: Float? = 0             // 面积
    public var price: Float? = 0       // 单价

    public var reciveorderTime: TimeInterval? = 0 // 接单时间

    public var payWay: String? = PayModel.PayType.unknown.rawValue
    public var addressInfo: AddressModel?
    
    public var remark: Remark?          // 备注

}

extension HouseKeepingModel {

    public class Remark: Codable {
        public var remark: String? = ""          // 备注
        public var reason: String? = ""          // 取消原因
        public var area: Float? = 0             // 面积
        public var price: Float? = 0       // 单价
    }

}

extension HouseKeepingModel {
    
    // 订单状态 all(全部）unpaid：待支付、 paid：待接单（已支付）、 recived：已接单、canceled：已取消、finished：已完成
    public enum Status: String {
        case unpaid
        case paid
        case recived
        case canceled
        case finished
        
        var description: String {
            switch self {
            case .unpaid:
                return "待支付"
            case .paid:
                return "待接单"
            case .recived:
                return "已接单"
            case .canceled:
                return "已取消"
            case .finished:
                return "已完成"
            }
        }
        
        var statusIcon: UIImage? {
            switch self {
            case .unpaid:
                return UIImage(named: "icon_order_status_waiting", in: Bundle.currentBase, compatibleWith: nil)
            case .paid:
                return UIImage(named: "icon_order_status_waiting", in: Bundle.currentBase, compatibleWith: nil)
            case .recived:
                return UIImage(named: "icon_order_status_undeliving", in: Bundle.currentBase, compatibleWith: nil)
            case .canceled:
                return UIImage(named: "icon_order_status_cancled", in: Bundle.currentBase, compatibleWith: nil)
            case .finished:
                return UIImage(named: "icon_order_status_finished", in: Bundle.currentBase, compatibleWith: nil)
            }
        }
        
        var statusPrompt: String {
            switch self {
            case .unpaid:
                return "家政服务服务等待支付"
            case .paid:
                return "家政服务等待接单"
            case .recived:
                return "已接单"
            case .finished:
                return "已完成"
            case .canceled:
                return "交易关闭"
            }
        }
        
        var emptyIcon: UIImage? {
            switch self {
            case .unpaid:
                return UIImage(named: "icon_order_empty", in: Bundle.currentBase, compatibleWith: nil)
            case .paid:
                return UIImage(named: "icon_order_empty", in: Bundle.currentBase, compatibleWith: nil)
            case .recived:
                return UIImage(named: "icon_order_empty", in: Bundle.currentBase, compatibleWith: nil)
            case .finished:
                return UIImage(named: "icon_order_completed_empty", in: Bundle.currentBase, compatibleWith: nil)
            case .canceled:
                return UIImage(named: "icon_order_canceled_empty", in: Bundle.currentBase, compatibleWith: nil)
            }
        }
        
        var emptyPrompt: String {
            switch self {
            case .unpaid:
                return "没有家政服务订单哦"
            case .paid:
                return "订单空空如也\n赶紧下单吧"
            case .recived:
                return "商家接单的订单才会出现在这哦~"
            case .finished:
                return "订单完成啦！\n土豪，我们做朋友吧！"
            case .canceled:
                return "取消之后的订单\n才可以在这里看哦"
            }
        }
    }
    
}
