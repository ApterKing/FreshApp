//
//  RegisterVModel.swift
//  FBusiness
//
//

import Foundation

class RegisterVModel: BaseVModel {
    
    public func regist(_ userPhone: String, _ checkCode: String, _ userLoginPassword: String, _ userInviteCode: String?, _ complection: ((_ model: TokenModel?, _ error: HttpError?) -> Void)?) {
        cancel()
        
        var params = [
            "userPhone": userPhone,
            "checkCode": checkCode,
            "userLoginPassword": userLoginPassword,
            "userRegFrom": "app"
        ]
        if let userInviteCode = userInviteCode {
            params["userInviteCode"] = userInviteCode
        }
        post(TokenModel.self, URLPath.User.regist, params) { [weak self] (data, error) in
            if let weakSelf = self, let data = data {
                UserVModel.default.currentToken = data
                UserVModel.default.userInfo(nil)
            }
            complection?(data, error)
        }
    }
    
    public func checkCode(_ phone: String, _ complection: ((_ model: BaseModel?, _ error: Error?) -> Void)?) {
        cancel()
        let params = [
            "userPhone": phone,
            "msgType": "sms_reg"
        ]
        get(BaseModel.self, URLPath.User.checkCode, params) { [weak self] (data, error) in
            complection?(data, error)
        }
    }

}
