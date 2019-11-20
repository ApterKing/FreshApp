//
//  OrderDetailVModel.swift
//  FBusiness
//
//

import UIKit

public class OrderDetailVModel: BaseVModel {
    
    var response: ResponseModel<[OrderDetailModel]>?
    var datas: [OrderDetailModel] = [OrderDetailModel]()
    var hasMore: Bool {
        return pageNo < response?.total ?? 0
    }
    
    private var pageNo = 1
    public func fetch(_ status: OrderModel.Status = .delivering, _ isRefresh: Bool, _ complection: ((_ error: HttpError?) -> Void)?) {
        let params: [String: Any] = [
            "status": status.rawValue,
            "pageNo": isRefresh ? 1 : pageNo + 1,
            "pageSize": Constants.pageSize,
        ]
        
        var urlPath = URLPath.User.orders
        if Bundle.bundleIdentifier != Constants.freshClientIndetifier {
            urlPath = URLPath.Delivery.order_list
        }

        cancel()
        get(ResponseModel<[OrderDetailModel]>.self, urlPath, params) { [weak self] (data, error) in
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

extension OrderDetailVModel {
    
    public func fetch(_ orderId: String, _ complection:((_ orderDetail: OrderDetailModel?, _ error: HttpError?) -> Void)?) {
        let params = [
            "orderId": orderId
        ]
        cancel()
        get(OrderDetailModel.self, URLPath.Order.detail, params) { (data, error) in
            complection?(data, error)
        }
    }
    
}
