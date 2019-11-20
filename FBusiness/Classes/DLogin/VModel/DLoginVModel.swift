//
//  DLoginVModel.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/25.
//

import UIKit
import SwiftX

public class DLoginVModel: BaseVModel {
    
    // 验证码登录
    public func loginWith(phone: String, code: String, _ complection: ((_ model: TokenModel?, _ error: HttpError?) -> Void)?) {
        cancel()
        let params = [
            "userPhone": phone,
            "checkCode": code
        ]
        get(TokenModel.self, URLPath.Delivery.login, params) { [weak self] (data, error) in
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
            "msgType": "sms_log"
        ]
        get(BaseModel.self, URLPath.Delivery.checkCode, params) { [weak self] (data, error) in
            complection?(data, error)
        }
    }

}

extension DLoginVModel {
    
    public func logout(_ complection: (() -> Void)?) {
        post(BaseModel.self, URLPath.Delivery.logout) { (_, _) in
            UserVModel.default.logout()
            complection?()
        }
    }
    
}
