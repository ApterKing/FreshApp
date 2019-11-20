//
//  CategorySubVModel.swift
//  FBusiness
//
//

import UIKit

class CategorySubVModel: BaseVModel {
    
    var response: ResponseModel<[ProductModel]>?
    var datas: [ProductModel] = [ProductModel]()
    var hasMore: Bool {
        return pageNo < response?.total ?? 0
    }

    var showMoreCell: Bool {
        return !hasMore && datas.count != 0
    }
    
    private var pageNo = 1
    func fetch(_ catelogId: String, _ isRefresh: Bool, _ complection: ((_ error: HttpError?) -> Void)?) {
        let params: [String: Any] = [
            "catelogId": catelogId,
            "pageNo": isRefresh ? 1 : pageNo + 1,
            "pageSize": Constants.pageSize,
            "cityId": CityVModel.default.currentCityCode
        ]

        cancel()
        get(ResponseModel<[ProductModel]>.self, URLPath.Product.list, params) { [weak self] (data, error) in
            if let weakSelf = self, let data = data {
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
