//
//  HomeMoreVModel.swift
//  FBusiness
//
//

class HomeMoreVModel: BaseVModel {

    var response: ResponseModel<[ProductModel]>?
    var datas: [ProductModel] = [ProductModel]()
    var hasMore: Bool {
        return pageNo < response?.total ?? 0
    }
    
    private var pageNo = 1
    func fetch(_ recommendId: String, _ isRefresh: Bool, _ complection: ((_ error: HttpError?) -> Void)?) {
        let params: [String: Any] = [
            "recommendId": recommendId,
            "pageNo": isRefresh ? 1 : pageNo + 1,
            "pageSize": Constants.pageSize,
            "cityId": CityVModel.default.currentCityCode
        ]
        
        if let data = local(URLPath.Product.categoryRecomment, params, to: ResponseModel<[ProductModel]>.self) {
            response = data
            pageNo = data.pageNo
            datas = data.data ?? []
            complection?(nil)
        }
        
        cancel()
        get(ResponseModel<[ProductModel]>.self, URLPath.Product.categoryRecommentList, params) { [weak self] (data, error) in
            if let weakSelf = self, let data = data {
                weakSelf.response = data
                weakSelf.pageNo = data.pageNo
                if isRefresh {
                    weakSelf.datas.removeAll()
                }
                weakSelf.datas.append(contentsOf: data.data ?? [])
                weakSelf.save(data, URLPath.Product.categoryRecomment, params, from: ResponseModel<[ProductModel]>.self)
            }
            complection?(error)
        }
    }
}
