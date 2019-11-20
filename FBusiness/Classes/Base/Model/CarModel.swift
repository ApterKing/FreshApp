//
//  CarModel.swift
//  FBusiness
//
//

public class CarModel: Codable {
    
    public var cartId: String = ""
    public var productId: String = ""
    public var pCatelogId: String? = ""    // 一级分类id
    public var productName: String? = ""
    public var productContent: String?  // 商品详细描述
    public var productDescription: String?  // 商品简短描述
    public var productType: String? = ProductModel.ProductType.normal.rawValue
    public var productThumbUrl: String?     // 缩略图
    
    public var productPrice: Float? = 0           // 正常价格
    public var productDiscountPrice: Float? = 0   // 折扣价
    public var productSpecialPrice: Float? = 0    // 特价
    
    public var productWeight: Int? = 0    //  包装数量
    public var productUnit: String?         // 计量单位
    public var formatProductUnit: String {
        get {
            let weight = productWeight ?? 0
            var unit = "/"
            if weight != 0 && weight != 1 {
                unit = "\(unit)\(weight)\(productUnit ?? "")"
            } else {
                unit = "\(unit)\(productUnit ?? "")"
            }
            return unit
        }
    }
    
    public var stock: Int? = 0       // 库存
    public var productStatus: ProductModel.Status? = .normal
    
    public var count: Int = 0

    // 本地使用
    public var isChecked: Bool? = true
}
