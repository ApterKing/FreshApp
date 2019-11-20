//
//  Constants.swift
//  FBusiness
//
//

import Toaster

public class Constants: NSObject {
    
    // 每页请求的数据条数
    static public let pageSize: Int = 15

}

//
public extension Constants {
 
    static public var defaultPlaceHolder: UIImage? {
        return nil
    }
    
    static public var freshClientIndetifier: String {
        return "com.xyd.fresh"
    }
    
    static public var freshDeliveryIndetifier: String {
        return "com.xyc.freshDelivery"
    }
    
}

public extension Constants {
    
    // 支付成功
    static public let notification_pay_success = Notification.Name(rawValue: "pay_success")
    
    // 家政支付成功
    static public let notification_pay_house_success = Notification.Name(rawValue: "pay_house_success")

    // 家政通知
    static public let notification_order_home_status_changed = Notification.Name("order_home_status_changed")
    
    // 取消订单成功
    static public let notification_order_canceled = Notification.Name(rawValue: "order_canceled")
    
    // 家政取消订单成功
    static public let notification_order_house_canceled = Notification.Name(rawValue: "order_house_canceled")
    
    // 城市改变
    static public let notification_city_changed = Notification.Name(rawValue: "city_changed")
    
    // 用户信息改变
    static public let notification_userInfo_changed = Notification.Name("userInfo_changed")
    
    // 用户注销
    static public let notification_user_logout = Notification.Name("user_logout")
    
    // 通知消息来的，订单状态改变
    static public let notification_order_status_changed = Notification.Name("order_status_changed")
    
    // tabar selectedIndex改变
    static public let notification_tabbar_selectedIndex_changed = Notification.Name("order_tabbar_selectedIndex_changed")
    
}

// UserDefaults存储的数据
public extension Constants {
    
    // 当前定位城市名称
    static public let current_loc_city = "current_loc_city"
    
    // 当前定位城市code
    static public let current_loc_city_code = "current_loc_city_code"
    
    // 当前选择的城市名称
    static public let current_sel_city = "current_sel_city"
    
    // 当前选择的城市code
    static public let current_sel_city_code = "current_sel_city_code"
}
