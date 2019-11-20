//
//  LoginVModel.swift
//  FBusiness
//
//


public class LoginVModel: BaseVModel {
    
    // 电话号码登录
    public func loginWith(phone: String, password: String, _ complection: ((_ model: TokenModel?, _ error: HttpError?) -> Void)?) {
        cancel()
        let params = [
            "userPhone": phone,
            "userLoginPassword": password,
            "userLoginWay": "app"
        ]
        get(TokenModel.self, URLPath.User.login, params) { (data, error) in
            if let data = data {
                UserVModel.default.currentToken = data
                UserVModel.default.userInfo(nil)
            }
            complection?(data, error)
        }
    }
    
    // 三方登录 (weixin/weibo/qq)
    public func loginWith(way: String, userRegId: String, _ complection: ((_ model: TokenModel?, _ error: HttpError?) -> Void)?) {
        cancel()
        let params = [
            "userLoginWay": way,
            "userRegId": userRegId,
        ]
        get(TokenModel.self, URLPath.User.login, params) { (data, error) in
            if let data = data {
                UserVModel.default.currentToken = data
                UserVModel.default.userInfo(nil)
            }
            complection?(data, error)
        }
    }
    
    public func logout(_ complection: (() -> Void)?) {
        post(BaseModel.self, URLPath.User.logout) { (_, _) in
            UserVModel.default.logout()
            complection?()
        }
    }

}
