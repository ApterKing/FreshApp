//
//  RetriveVModel.swift
//  FBusiness
//
//

import UIKit

class ResetVModel: BaseVModel {
   
    public func reset(_ oldPassword: String, _ newPassword: String, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)?) {
        cancel()
        
        let params = [
            "oldPassword": oldPassword,
            "newPassword": newPassword,
        ]
        post(BaseModel.self, URLPath.User.updPwd, params) { (data, error) in
            complection?(data, error)
        }
    }
    

}
