//
//  RegisterVModel.swift
//  FBusiness
//
//  Created by wangcong on 2019/2/22.
//

import Foundation

class DRegisterVModel: BaseVModel {
    
    public func regist(_ userPhone: String, _ checkCode: String, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)?) {
        cancel()
        
        var params = [
            "userPhone": userPhone,
            "checkCode": checkCode,
        ]
        post(BaseModel.self, URLPath.Delivery.regist, params) { [weak self] (data, error) in
            complection?(data, error)
        }
    }
    
    public func checkCode(_ phone: String, _ complection: ((_ model: BaseModel?, _ error: Error?) -> Void)?) {
        cancel()
        let params = [
            "userPhone": phone,
            "msgType": "sms_reg"
        ]
        get(BaseModel.self, URLPath.Delivery.checkCode, params) { [weak self] (data, error) in
            complection?(data, error)
        }
    }

}
