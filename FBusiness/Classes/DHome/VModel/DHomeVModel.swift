//
//  DHomeVModel.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/25.
//

class DHomeVModel: BaseVModel {

}

extension DHomeVModel {
    func finish(orderId: String, checkCode: String, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)?) {
        let params = [
            "orderId": orderId,
            "orderCheckCode": checkCode
        ]
        post(BaseModel.self, URLPath.Delivery.order_finish, params) { (data, error) in
            complection?(data, error)
        }
    }
}

extension DHomeVModel {
    
    func take(orderId: String, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)?) {
        let params = [
            "orderId": orderId,
        ]
        get(BaseModel.self, URLPath.Delivery.order_get, params) { (data, error) in
            complection?(data, error)
        }
    }
    
}
