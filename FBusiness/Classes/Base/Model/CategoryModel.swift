//
//  CategoryModel.swift
//  FBusiness
//
//

public class CategoryModel: Codable {
    
    public var catelogId: String = ""       // 分类id
    public var catelogName: String = ""
    public var pcatelogId: String?
    public var catelogThumbUrl: String = ""
    public var config: Config?
    
    public var subs: [CategoryModel]?
    
    // 仅本地使用
    public var discount: UserModel.Config.Discount?
}

public extension CategoryModel {
    
    public class Config: Codable {
        
        public var minConsum: Float? = 0  // 最低消费金额
        public var discount: Float? = 0   // 折扣率
        
    }
    
}
