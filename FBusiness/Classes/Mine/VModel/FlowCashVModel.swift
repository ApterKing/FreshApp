//
//  FlowCashVModel.swift
//  FBusiness
//
//

class FlowCashVModel: BaseVModel {
    
    var response: ResponseModel<[FlowCashModel]>?
    var datas: [FlowCashModel] = [FlowCashModel]()
    var hasMore: Bool {
        return pageNo < response?.total ?? 0
    }
    
    private var pageNo = 1
    func fetch(_ isRefresh: Bool, _ complection: ((_ error: HttpError?) -> Void)?) {
        let params: [String: Any] = [
            "pageNo": isRefresh ? 1 : pageNo,
            "pageSize": Constants.pageSize,
        ]
        
        cancel()
        get(ResponseModel<[FlowCashModel]>.self, URLPath.User.cashFlow, params) { [weak self] (data, error) in
            if let weakSelf = self, let data = data {
                weakSelf.response = data
                weakSelf.pageNo = data.pageNo
                weakSelf.datas = data.data ?? []
            }
            complection?(error)
        }
    }

}

extension FlowCashVModel {
    
    func apply(_ money: Float, complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)?) {
        let params = [
            "money": money
        ]
        post(BaseModel.self, URLPath.User.withdraw, params) { (data, error) in
            complection?(data, error)
        }
    }
    
}
