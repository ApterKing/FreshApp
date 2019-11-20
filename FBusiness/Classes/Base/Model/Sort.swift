//
//  Sort.swift
//  FBusiness
//
//

public class Sort: NSObject {

}

public extension Sort {
   
    /// 排序字段（createTime：新品优先、productDiscountPrice：价格）
    public enum OrderBy: String {
        case createTime
        case productDiscountPrice
    }
}

public extension Sort {
    
    /// 排序（ASC：升序、DESC：降序）
    public enum OrderAs: String {
        case ASC
        case DESC
    }
    
}
