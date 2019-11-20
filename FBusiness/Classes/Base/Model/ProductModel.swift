//
//  ProductModel.swift
//  FBusiness
//
//

public class ProductModel: Codable {
    
    public var productId: String = ""
    public var pCatelogId: String?       // 二级分类id
    public var catelogId: String?
    public var productName: String? = ""
    public var productContent: String?  // 商品详细描述
    public var productDescription: String?  // 商品简短描述
    public var productType: String? = ProductType.normal.rawValue
    public var productThumbUrl: String?     // 缩略图
    
    public var productWeight: Int? = 0    //  包装数量
    public var productUnit: String? = ""    // 单位
    
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
    
    public var productPrice: Float? = 0           // 正常价格
    public var productDiscountPrice: Float? = 0   // 折扣价
    public var productSpecialPrice: Float? = 0    // 特价
    public var stock: Int?                   // 库存
    public var resources: [Resource]? = []
    
    // 仅本地使用
    public var count: Int? = 0                  // 商品数量

    public var productStatus: ProductModel.Status? = .normal
}

public extension ProductModel {
    
    /// 商品类型（specialPrice：特价商品、normal：普通商品【不填默认normal】、userDiscount: 用户专属优惠、分类折扣）
    public enum ProductType: String {
        case specialPrice
        case userDiscount
        case category
        case normal
        
        var description: String {
            switch self {
            case .specialPrice:
                return "特价商品"
            case .userDiscount:
                return "专属优惠"
            case .category:
                return "分类折扣"
            default:
                return "普通商品"
            }
        }
    }
    
}

public extension ProductModel {

    //（normal：正常、out：售罄、obtained：下架）
    public enum Status: String, Codable {
        case normal
        case out
        case obtained
    }

}

public extension ProductModel {
    
    public class Resource: Codable {
        
        public var resourceId: String = ""
        public var fileType: String? = ResourceType.img.rawValue
        
        public var resourceUrl: String?
        public var thumbUrl: String?
    }
    
}

public extension ProductModel.Resource {
    
    // 资源文件类型：img：图片、 doc：文档文件、video：视频
    public enum ResourceType: String {
        case img
        case doc
        case video
    }
    
}
