//
//  CommissionModel.swift
//  FBusiness
//
//

public class CommissionModel: Codable {
    
    // 一级
    public var i1Commission: Float = 0
    public var i1CommissionValidDays: Int = 0
    
    // 二级
    public var i2Commission: Float = 0
    public var i2CommissionValidDays: Int = 0
    
    // 折扣券
    public var invitedDiscountCoupon: Float = 0
    public var invitedDiscountCouponValidDays: Int = 0
    
    // 抵扣券
    public var invitedDeductionCoupon: String = "100#-50"  //被邀请抵扣券，数据格式：100#-50（满100减50）
    public var invitedDeductionCouponValidDays: Int = 0
    
    
    // 第一次注册或者绑定时优惠券选择
    public var invitedDeductionDiscountConfig: String = Config.none.rawValue

}

public extension CommissionModel {
    // both：优惠券、抵扣券 /option：二选一  /none：无优惠
    public enum Config: String {
        case none
        case both
        case option
    }
    
}
