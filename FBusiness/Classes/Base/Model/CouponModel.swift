//
//  CouponModel.swift
//  FBusiness
//
//

public class CouponModel: Codable {
    
    public var userCouponId: String?
    
    public var couponId: String = ""
    public var couponName: String = ""
    public var couponDescription: String = ""
    public var couponExpiredTime: TimeInterval = 0
    public var couponStatus: String = Status.enable.rawValue
    public var couponMoney: Float = 0
    public var couponCount: Int = 0
    public var couponType: String = CouponType.discount.rawValue
    public var couponConfig: Config?
}

// 优惠券状态
public extension CouponModel {
    
    public enum Status: String {
        case enable
        case disable
    }
    
}

public extension CouponModel {
    
    public class Config: Codable {
        public var discount: Float? = 1
        public var minConsum: Float? = 0     // 最低消费金额
        public var reduce: Float? = 0        // 抵扣金额
    }
}

public extension CouponModel {
    
    public enum CouponType: String {
        case discount       // 折扣券
        case deduction      // 抵扣券
        
        public var description: String {
            switch self {
            case .discount:
                return "折扣券"
            default:
                return "抵扣券"
            }
        }
    }
    
}
