//
//  FlowCashModel.swift
//  FBusiness
//
//

// 用户支持明细
public class FlowCashModel: Codable {
    
    public var flowName: String = ""
    public var flowType: String = FlowType.order.rawValue
    public var flowPayType: String = PayModel.PayType.unknown.rawValue
    public var flowMoney: Float = 0
    public var flowFrom: String = ""   // 流水来源
    public var fromUserName: String? = "--"
    public var flowTime: TimeInterval = 0
    
    public var flowStatus: String = Status.paid.rawValue   // 流水状态

    public var flowExtends: String?  // 驳回原因
}

public extension FlowCashModel {
    
    /// 流水类型（order：订单支付、reg：注册提成、withdraw：提现）
    public enum FlowType: String {
        case order
        case reg
        case reg1
        case reg2
        case withdraw
        case refund
        case clearTrust
        
        var description: String {
            switch self {
            case .order:
                return "订单支付"
            case .reg:
                return "一级返佣"
            case .reg1:
                return "一级返佣"
            case .reg2:
                return "二级返佣"
            case .refund:
                return "退款"
            case .clearTrust:
                return "清账"
            default:
                return "--"
            }
        }
    }
    
}

public extension FlowCashModel {
    
    // 流水支付状态（paid：已支付、unpaid：未支付、canceled：已取消）
    public enum Status: String {
        case paid
        case unpaid
        case canceled
        
        var description: String {
            switch self {
            case .paid:
                return "已支付"
            case .unpaid:
                return "未支付"
            default:
                return "已取消"
            }
        }
    }
    
}
