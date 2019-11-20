//
//  RecommendModel.swift
//  FBusiness
//
//

// 首页推荐
public class RecommendModel: Codable {
    
    public var recommendId: String = ""
    public var recommendName: String = ""
    public var recommendThumbUrl: String = ""
    public var recommendType: String = RecommendType.catelog.rawValue
//    public var sellTime: [Int]?
    public var products: [ProductModel]? = []
}

public extension RecommendModel {
    
    /// 推荐类型（catelog：分类、limitTime：限时秒杀）
    public enum RecommendType: String {
        case catelog
        case limitTime
    }
    
}
