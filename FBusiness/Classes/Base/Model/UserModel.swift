//
//  UserModel.swift
//  FBusiness
//
//

public class UserModel: Codable {
    
    public var userId: String = ""
    public var userName: String = ""
    public var userPhone: String? = ""
    public var userScore: Int? = 0   // 用户积分
    public var userBalance: Float? = 0   // 用户余额
    public var userSexual: String? = Sexual.male.rawValue

    public var userType: String? = UserType.unknown.rawValue  // 用户类型
    public var userThumb: String?       // 用户头像
    public var userInviteCode: String?  // 用户邀请码
    public var from1UserCode: String?   // 来自邀请用户的邀请码
    
    // 申请提现需要的参数
    public var userWithdraw: Float? = 0
    public var alipay: Alipay?
    
    public var config: Config?
    
}

// 性别
public extension UserModel {
    
    public enum Sexual: String {
        case male
        case female
    }
    
}

// 配置
public extension UserModel {
    
    public class Config: Codable {
        
        public var trustAccount: TrustAccount?
        public var discounts: [Discount]? = [Discount]()
        
    }
    
}

// 账期配置
public extension UserModel.Config {
    
    public class TrustAccount: Codable {
        public var maxBanlance: Float? = 0       // 最大账期
        public var usedBanlace: Float? = 0      // 已用账期
        public var minPeriod: Int? = 0        // 可用周期
        public var maxPeriod: Int? = 0        // 最大周期
    }
    
}

// 折扣配置
public extension UserModel.Config {
    
    public class Discount: Codable {
        
        public var catelogId: String = "0"      // 折扣分类Id (一级分类id)
        public var catelogName: String? = "0"    // 折扣分类名称
        public var discount: Float? = 0          // 折扣率
        
    }
    
}

// 用户类型
public extension UserModel {
    
    public enum UserType: String {
        case unknown
        case consumer   // 普通用户
        case shop       // 商户用户
        case deliver    // 配送员
    }
}

public extension UserModel {
    
    public class Alipay: Codable {
        public var name: String?
        public var account: String?
    }
    
}
