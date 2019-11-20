//
//  OrderDetailModel.swift
//  FBusiness
//
//

public class OrderDetailModel: Codable {
    
    public var products: [ProductModel]? = []
    public var order: OrderModel?
    public var addressInfo: AddressModel?
    public var delivery: UserModel?         // 配送员
    
}
