//
//  InviteCodeVModel.swift
//  FBusiness
//
//

import UIKit

class InviteCodeVModel: BaseVModel {

    public func bind(_ code: String, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)?) {
        cancel()

        let params = [
            "inviteCode": code,
            ]
        post(BaseModel.self, URLPath.User.regInviteCode, params) { (data, error) in
            complection?(data, error)
        }
    }

}
