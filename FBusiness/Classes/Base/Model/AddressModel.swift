//
//  AddressModel.swift
//  FBusiness
//
//

public class AddressModel: Codable {
    
    public var addressId: String?
    public var userName: String = ""    // 收货人姓名
    public var sexual: String? = UserModel.Sexual.male.rawValue
    public var userPhone: String = ""     // 收货人电话
    public var label: String?       // 地址标签，如：家
    public var area: String?        // 地址范围（例如：四川省 成都市 高新区）
    public var userAddress: String? // 详细的门牌号等
    public var longitude: String?
    public var latitude: String?
    public var isDefault: String? = "no"   //  yes  no 是否为默认地址
    public var address: String?
    
}
