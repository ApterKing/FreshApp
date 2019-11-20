//
//  ForgetVModel.swift
//  FBusiness
//
//

import UIKit

class ForgetVModel: BaseVModel {
    
    public func forget(_ userPhone: String, _ checkCode: String, _ userLoginPassword: String, _ complection: ((_ model: TokenModel?, _ error: HttpError?) -> Void)?) {
        cancel()
        
        let params = [
            "userPhone": userPhone,
            "checkCode": checkCode,
            "newPassword": userLoginPassword,
        ]
        get(TokenModel.self, URLPath.User.forgotPwd, params) { [weak self] (data, error) in
            complection?(data, error)
        }
    }
    
    public func checkCode(_ phone: String, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)?) {
        cancel()
        let params = [
            "userPhone": phone,
            "msgType": "sms_upd"
        ]
        get(BaseModel.self, URLPath.User.checkCode, params) { [weak self] (data, error) in
            complection?(data, error)
        }
    }
    
}
