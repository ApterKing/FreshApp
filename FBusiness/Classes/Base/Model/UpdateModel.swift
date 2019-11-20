//
//  UpdateModel.swift
//  FBusiness
//
//

public class UpdateModel: Codable {
    
    public var versionId: String = ""
    public var versionName: String = ""
    public var versionNo: String = ""
    public var isFUpdate: String = ""
    public var versionUrl: String = ""
    public var osType: String = ""
    public var appType: String = "iOS"
    public var content: String = ""
    
}

public extension UpdateModel {
    
    public enum OSType: String {
        case iOS
        case Android
    }
    
    public enum APPType: String {
        case consumer
        case deliver
    }
    
}
