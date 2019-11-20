//
//  CityModel.swift
//  FBusiness
//
//


public class CityModel: Codable {
    
    public var cityId: String = ""
    public var cityCode: String = ""
    public var cityType: String = "2"  // （1：省、2：市、3：区/县）
    public var isOpen: String = "yes"
    public var cityName: String = ""
    public var config: Config?

}

extension CityModel {
    
    public class Config: Codable {
        
        public var orderDeadline: String = ""       // 订单截至时间
        public var homeServiceFee: Float = 0    // 家政服务价格
        
    }
    
}
