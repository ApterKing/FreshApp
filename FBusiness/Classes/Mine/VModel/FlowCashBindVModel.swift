//
//  FlowCashBindVModel.swift
//  FBusiness
//
//

class FlowCashBindVModel: BaseVModel {
    
    public func bind(_ name: String, _ account: String, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)?) {
        cancel()
        
        let params = [
            "alipayUserName": name,
            "alipayAccount": account,
        ]
        multiUpload(BaseModel.self, URLPath.User.update, params, nil) { (data, error) in
            complection?(data, error)
        }
    }

}
