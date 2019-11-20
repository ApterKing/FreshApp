//
//  ConfigModel.swift
//  FBusiness
//
//

public class ConfigModel: Codable {
    
    public var configId: String = ""
    public var configName: String?
    public var configType: String = ConfigType.startup.rawValue
    public var configDataType: String = DataType.unknown.rawValue
    public var cityId: String?
    public var data: String = ""        // products：对应二级分类ID; catelogs：对应一级分类ID; product：对应商品ID; 对应的外链地址
    public var configImgUrl: String = ""

}

// 配置类型
public extension ConfigModel {
    
    public enum ConfigType: String {
        case startup
        case banner
    }
    
}

// 数据类型
public extension ConfigModel {
    
    public enum DataType: String {
        case unknown
        case products           // 商品列表
        case catelogs           // 分类
        case product            // 商品详情
        case url                // 外链地址
    }
    
}
