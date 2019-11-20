//
//  DeliveryTimeModel.swift
//  FBusiness
//
//

public class DeliveryTimeModel: Codable {
    
    public var deliverStartTime: String = ""
    public var deliverEndTime: String = ""
    public var isDeliverFree: String = "no"   // yes no
    public var deliverFreeOrderMoney: Float? = 0  // 免单价格
    public var deliveryMoney: Float = 0      // 配送费
    public var maxOrderCount: Int = 0        // 最大订单量
    public var enable: String = "yes"    // yes no
    
}
