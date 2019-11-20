//
//  SearchVModel.swift
//  FBusiness
//
//

import UIKit

class SearchVModel: BaseVModel {
    
    var response: ResponseModel<[ProductModel]>?
    var datas: [ProductModel] = [ProductModel]()
    var hasMore: Bool {
        return pageNo < response?.total ?? 0
    }

    var showMoreCell: Bool {
        return !hasMore && datas.count != 0
    }

    private var pageNo = 1
    func fetch(_ keyword: String, _ isRefresh: Bool, _ complection: ((_ error: HttpError?) -> Void)?) {
        let params: [String: Any] = [
            "keyword": keyword,
            "pageNo": isRefresh ? 1 : pageNo,
            "pageSize": Constants.pageSize,
            "cityId": CityVModel.default.currentCityCode
        ]

        cancel()
        post(ResponseModel<[ProductModel]>.self, URLPath.Product.list, params) { [weak self] (data, error) in
            if let weakSelf = self, let data = data {
                weakSelf.response = data
                weakSelf.pageNo = data.pageNo
                weakSelf.datas = data.data ?? []
            }
            complection?(error)
        }
    }
}
