//
//  HomeVModel.swift
//  FBusiness
//
//

import UIKit

class HomeVModel: BaseVModel {
    
    // 置顶
    var topDatas: [ConfigModel] = [ConfigModel]()
    private let topVModel = HomeTopVModel()
    
    // 分类
    var categoryDatas: [CategoryModel] = [CategoryModel]()
    private let categoryVModel = HomeCategoryVModel()
    
    // 特价商品
    var specialDatas: [ProductModel] = [ProductModel]()
    private let specialVModel = HomeSpecialVModel()
    
    // 推荐
    var recommends: [RecommendModel] = []
    
    func fetch(_ complection: ((_ isRecommend: Bool, _ error: Error?) -> Void)?) {

        // 刷新下默认的分类数据
        CategoryVModel.default.shouldShowToastWhen500Upper = false
        CategoryVModel.default.fetch(nil)
        
        cancel()
        topVModel.fetch { [weak self] (error) in
            guard let weakSelf = self else { return }
            if error == nil {
                weakSelf.topDatas = weakSelf.topVModel.datas
            } else {
                weakSelf.topDatas = []
            }
            complection?(false, error)
        }
        
        // 刷新一下城市数据
        CityVModel.default.fetch { [weak self] (_) in
            guard let weakSelf = self else { return }
            weakSelf.categoryVModel.fetch {  (error) in
                if error == nil {
                    weakSelf.categoryDatas = weakSelf.categoryVModel.datas
                } else {
                    weakSelf.categoryDatas = []
                }
                complection?(false, error)
            }
        }
        
        specialVModel.fetch { [weak self] (error) in
            guard let weakSelf = self else { return }
            if error == nil {
                weakSelf.specialDatas = weakSelf.specialVModel.datas
            } else {
                weakSelf.specialDatas = []
            }
            complection?(false, error)
        }

        let params: [AnyHashable: Any] = [
            "cityId": CityVModel.default.currentCityCode
        ]
        get([RecommendModel].self, URLPath.Product.categoryRecomment, params) { [weak self] (data, error) in
            if let weakSelf = self, let data = data {
                weakSelf.recommends = data
            }
            complection?(false, error)
        }
    }
    
}

// 置顶
private class HomeTopVModel: BaseVModel {
    
    var datas: [ConfigModel] = [ConfigModel]()
    private let vmodel = ConfigVModel()
    
    func fetch(_ complection: ((_ error: HttpError?) -> Void)?) {
        vmodel.fetch(.banner) { [weak self] (data, error) in
            self?.datas = data
            complection?(error)
        }
    }
}

// 分类
private class HomeCategoryVModel: BaseVModel {
    
    var datas: [CategoryModel] = [CategoryModel]()
    
    func fetch(_ complection: ((_ error: HttpError?) -> Void)?) {
        if let cachedData = local(URLPath.Product.categoryFront, nil, to: [CategoryModel].self) {
            datas = cachedData
            complection?(nil)
        }
        
        cancel()
        let params: [AnyHashable: Any] = [
            "cityId": CityVModel.default.currentCityCode
        ]
        get([CategoryModel].self, URLPath.Product.categoryFront, params) { [weak self] (data, error) in
            if let weakSelf = self, let data = data {
                weakSelf.datas = data
                
                weakSelf.save(data, URLPath.Product.categoryFront, nil, from: [CategoryModel].self)
            }
            complection?(error)
        }
    }
    
}

// 首页特价商品
private class HomeSpecialVModel: BaseVModel {
    
    var datas: [ProductModel] = [ProductModel]()
    
    func fetch(_ complection: ((_ error: HttpError?) -> Void)?) {
        let params: [String: Any] = [
            "productType": "specialPrice",
            "pageNo": 1,
            "pageSize": 10,
            "cityId": CityVModel.default.currentCityCode
        ]
        if let cachedData = local(URLPath.Product.list, params, to: ResponseModel<[ProductModel]>.self) {
            datas = cachedData.data ?? []
            complection?(nil)
        }
        
        cancel()
        get(ResponseModel<[ProductModel]>.self, URLPath.Product.list, params) { [weak self] (data, error) in
            if let weakSelf = self, let data = data {
                weakSelf.datas = data.data ?? []
                
                weakSelf.save(data, URLPath.Product.list, params, from: ResponseModel<[ProductModel]>.self)
            }
            complection?(error)
        }
    }
    
}

