//
//  HouseKeepingVmodel.swift
//  FBusiness
//
//

public class HouseKeepingVModel: BaseVModel {
    
    var response: ResponseModel<[HouseKeepingModel]>?
    var datas: [HouseKeepingModel] = [HouseKeepingModel]()
    var hasMore: Bool {
        return pageNo < response?.total ?? 0
    }
    
    private var pageNo = 1
    public func fetch(_ status: HouseKeepingModel.Status = .unpaid, _ isRefresh: Bool, _ complection: ((_ error: HttpError?) -> Void)?) {
        let params: [String: Any] = [
            "orderStatus": status.rawValue,
            "pageNo": isRefresh ? 1 : pageNo + 1,
            "pageSize": Constants.pageSize,
        ]
        
        cancel()
        get(ResponseModel<[HouseKeepingModel]>.self, URLPath.Order.homeServiceList, params) { [weak self] (data, error) in
            guard let weakSelf = self else { return }
            if let data = data {
                weakSelf.response = data
                weakSelf.pageNo = data.pageNo
                if isRefresh {
                    weakSelf.datas.removeAll()
                }
                weakSelf.datas.append(contentsOf: data.data ?? [])
            }
            complection?(error)
        }
    }
}

extension HouseKeepingVModel {
    
    // 提交服务订单（账期支付返回的数据格式不一样）
    public func add(_ params: [AnyHashable: Any], _ payType: PayModel.PayType, _ complection: ((_ model: PayModel?, _ error: HttpError?) -> Void)?) {
        cancel()
        switch payType {
        case .trustAccount:
            post(BaseModel.self, URLPath.Order.homeServiceAdd, params) { (baseModel, error) in
                if baseModel != nil {
                    let payModel = PayModel()
                    payModel.trustAccount = true
                    complection?(payModel, nil)
                } else {
                    complection?(nil, error)
                }
            }
        default:
            post(PayModel.self, URLPath.Order.homeServiceAdd, params) { (payModel, error) in
                complection?(payModel, error)
            }
        }
    }
    
    public func cancel(_ orderId: String, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)?) {
        let params = [
            "orderId": orderId,
            "reason": "用户主动取消"
        ]
        cancel()
        post(BaseModel.self, URLPath.Order.homeServiceCancel, params) { (data, error) in
            complection?(data, error)
        }
    }
    
    // 支付待支付的订单
    public func pay(_ orderId: String, _ payType: PayModel.PayType, _ complection: ((_ model: PayModel?, _ error: HttpError?) -> Void)?) {
        let params = [
            "orderId": orderId,
            "payWay": payType.rawValue
        ]
        cancel()
        switch payType {
        case .trustAccount:
            post(BaseModel.self, URLPath.Order.homeServicePay, params) { (baseModel, error) in
                if baseModel != nil {
                    let payModel = PayModel()
                    payModel.trustAccount = true
                    complection?(payModel, nil)
                } else {
                    complection?(nil, error)
                }
            }
        default:
            post(PayModel.self, URLPath.Order.homeServicePay, params) { (payModel, error) in
                complection?(payModel, error)
            }
        }
    }

}
