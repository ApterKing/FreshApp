//
//  OrderModel.swift
//  FBusiness
//
//

public class OrderModel: Codable {
    
    public var orderId: String = ""
    public var orderTime: TimeInterval = 0
    public var orderOrgMoney: Float? = 0
    public var orderMoney: Float = 0
    public var total: Float = 0   // 配送费 + 订单价格
    public var orderSNo: String = ""        // 订单号
    public var orderStatus: String = Status.undeliver.rawValue
    
    public var reciveOrderTime: TimeInterval? = 0 // 接单时间
    public var orderCheckCode: String? = ""        // 收货码

    public var addressId: String?
    public var addressInfo: AddressModel?

    public var products: [ProductModel]? = [ProductModel]()
    
    public var stationAddress: String? = ""  // 配送站点
    public var deliverFee: Float = 0      // 0 免配送费
    public var deliveryStartTime: TimeInterval = 0
    public var deliveryEndTime: TimeInterval = 0
    public var payWay: String? = PayModel.PayType.unknown.rawValue
    
    public var couponId: String? = ""          // 优惠券Id

    public var remark: Remark?          // 备注等
    
    public var doneTime: TimeInterval? = 0

}

public extension OrderModel {

    public class Remark: Codable {
        public var remark: String? = ""          // 备注
        public var reason: String? = ""          // 取消原因
    }

}

public extension OrderModel {
    
    // 订单状态 all(全部）unpaid：待支付、 paid：待接单（已支付）、 undeliver：待配送、 delivering：配送中、canceled：已取消、finished：已完成
    public enum Status: String {
        case all
        case unpaid
        case paid
        case undeliver
        case delivering
        case canceled
        case finished
        
        var description: String {
            switch self {
            case .all:
                return "全部"
            case .unpaid:
                return "待支付"
            case .paid:
                return "待接单"
            case .undeliver:
                return "待配送"
            case .delivering:
                return "配送中"
            case .canceled:
                return "已取消"
            case .finished:
                return "已完成"
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .all:
                return UIImage(named: "icon_order_unreceive", in: Bundle.currentBase, compatibleWith: nil)
            case .unpaid:
                return UIImage(named: "icon_order_unreceive", in: Bundle.currentBase, compatibleWith: nil)
            case .paid:
                return UIImage(named: "icon_order_unreceive", in: Bundle.currentBase, compatibleWith: nil)
            case .undeliver:
                return UIImage(named: "icon_order_undeliver", in: Bundle.currentBase, compatibleWith: nil)
            case .delivering:
                return UIImage(named: "icon_order_delivering", in: Bundle.currentBase, compatibleWith: nil)
            case .finished:
                return UIImage(named: "icon_order_completed", in: Bundle.currentBase, compatibleWith: nil)
            case .canceled:
                return UIImage(named: "icon_order_canceled", in: Bundle.currentBase, compatibleWith: nil)
            }
        }
        
        var statusIcon: UIImage? {
            switch self {
            case .all:
                return UIImage(named: "icon_order_status_waiting", in: Bundle.currentBase, compatibleWith: nil)
            case .unpaid:
                return UIImage(named: "icon_order_status_waiting", in: Bundle.currentBase, compatibleWith: nil)
            case .paid:
                return UIImage(named: "icon_order_status_waiting", in: Bundle.currentBase, compatibleWith: nil)
            case .undeliver:
                return UIImage(named: "icon_order_status_undeliving", in: Bundle.currentBase, compatibleWith: nil)
            case .delivering:
                return UIImage(named: "icon_order_status_deliving", in: Bundle.currentBase, compatibleWith: nil)
            case .finished:
                return UIImage(named: "icon_order_status_finished", in: Bundle.currentBase, compatibleWith: nil)
            case .canceled:
                return UIImage(named: "icon_order_status_cancled", in: Bundle.currentBase, compatibleWith: nil)
            }
        }
        
        var statusPrompt: String {
            switch self {
            case .all:
                return ""
            case .unpaid:
                return "订单等待支付"
            case .paid:
                return "等待卖家接单"
            case .undeliver:
                return "等待配送员送货"
            case .delivering:
                return "订单正在配送中"
            case .finished:
                return "订单已完成"
            case .canceled:
                return "交易关闭"
            }
        }
        
        var emptyIcon: UIImage? {
            switch self {
            case .all:
                return UIImage(named: "icon_order_empty", in: Bundle.currentBase, compatibleWith: nil)
            case .unpaid:
                return UIImage(named: "icon_order_empty", in: Bundle.currentBase, compatibleWith: nil)
            case .paid:
                return UIImage(named: "icon_order_empty", in: Bundle.currentBase, compatibleWith: nil)
            case .undeliver:
                return UIImage(named: "icon_order_undeliver_empty", in: Bundle.currentBase, compatibleWith: nil)
            case .delivering:
                return UIImage(named: "icon_order_delivering_empty", in: Bundle.currentBase, compatibleWith: nil)
            case .finished:
                return UIImage(named: "icon_order_completed_empty", in: Bundle.currentBase, compatibleWith: nil)
            case .canceled:
                return UIImage(named: "icon_order_canceled_empty", in: Bundle.currentBase, compatibleWith: nil)
            }
        }
        
        var emptyPrompt: String {
            switch self {
            case .all:
                return "订单空空如也\n赶紧去逛逛吧"
            case .unpaid:
                return "订单空空如也\n赶紧去逛逛吧"
            case .paid:
                return "订单空空如也\n赶紧去逛逛吧"
            case .undeliver:
                #if FRESH_CLIENT
                return "只有付款完成的订单\n才会在这里出现哦"
                #else
                return "系统当前还未给您派单哟~"
                #endif
            case .delivering:
                #if FRESH_CLIENT
                return "送货小哥严阵以待\n订单出发后可在这里查看"
                #else
                return "当前没有正在派送的订单\n请前往代配送查看吧~"
                #endif
            case .finished:
                return "订单完成啦！\n土豪，我们做朋友吧！"
            case .canceled:
                return "取消之后的订单\n才可以在这里看哦"
            }
        }
    }
    
}
