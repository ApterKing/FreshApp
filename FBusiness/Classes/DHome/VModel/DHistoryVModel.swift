//
//  DHistoryVModel.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/27.
//

class DHistoryVModel: BaseVModel {
    
    var response: ResponseModel<[OrderDetailModel]>?
    var datas: [OrderDetailModel] = [OrderDetailModel]()
    var hasMore: Bool {
        return pageNo < response?.total ?? 0
    }
    
    private var pageNo = 1
    public func fetch(_ isRefresh: Bool, _ complection: ((_ error: HttpError?) -> Void)?) {
        let params: [String: Any] = [
            "pageNo": isRefresh ? 1 : pageNo + 1,
            "pageSize": Constants.pageSize,
        ]
        
        cancel()
        get(ResponseModel<[OrderDetailModel]>.self, URLPath.Delivery.order_history, params) { [weak self] (data, error) in
            guard let weakSelf = self else { return }
            if let data = data {
                weakSelf.response = data
                weakSelf.pageNo = data.pageNo
                if isRefresh {
                    weakSelf.datas.removeAll()
                }
                weakSelf.datas.append(contentsOf: data.data ?? [])
                weakSelf.save(data, URLPath.Delivery.order_history, params, from: ResponseModel<[OrderDetailModel]>.self)
            } else if error != nil {  // 存在错误从本地取数据
                if isRefresh {
                    weakSelf.datas.removeAll()
                }
                if let data = weakSelf.local(URLPath.Delivery.order_history, params, to: ResponseModel<[OrderDetailModel]>.self) {
                    weakSelf.response = data
                    weakSelf.pageNo = data.pageNo
                    weakSelf.datas = data.data ?? []
                    complection?(nil)
                }
            }
            complection?(error)
        }
    }
    
}

extension DHistoryVModel {
    
    func statistic(_ complection: ((_ model: StatisticModel?, _ error: HttpError?) -> Void)?) {
        get(StatisticModel.self, URLPath.Delivery.order_statistic) { (data, error) in
            complection?(data, error)
        }
    }
    
}
