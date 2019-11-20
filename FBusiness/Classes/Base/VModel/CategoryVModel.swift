//
//  CategoryVModel.swift
//  FBusiness
//
//

public class CategoryVModel: BaseVModel {
    
    static let `default` = CategoryVModel()
    
    var datas: [CategoryModel] = [CategoryModel]()
    
    public func fetch(_ complection: ((_ error: HttpError?) -> Void)?) {
        
        if let data = local(URLPath.Product.category, nil, to: [CategoryModel].self) {
            datas = data
            complection?(nil)
        }
        
        cancel()
        let params: [AnyHashable: Any] = [
            "cityId": CityVModel.default.currentCityCode
        ]
        get([CategoryModel].self, URLPath.Product.category, params) { [weak self] (data, error) in
            if let weakSelf = self, let data = data {
                weakSelf.datas = data
                
                weakSelf.save(data, URLPath.Product.category, nil, from: [CategoryModel].self)
            }
            complection?(error)
        }
    }

    // 通过一级categoryId判定是否需要显示顶部提示
    public func shouldShowSuspendSaleHeaderPrompt(levelOne categoryId: String?) -> Bool {
        guard let categoryId = categoryId else {
            return false
        }
        for data in datas {
            if data.catelogId == categoryId &&
                data.catelogName == "水果" {
                return true
            }
        }
        return false
    }

    // 通过一级categoryId判定是否需要显示暂停销售提示
    public func shouldShowSuspendSalePrompt(levelOne categoryId: String?) -> Bool {
        guard let categoryId = categoryId else {
            return false
        }
        let dateString = Date().format(to: "HH:mm")
        let orderDateTime = CityVModel.default.currentCity?.config?.orderDeadline ?? "21:00"
        for data in datas {
            if data.catelogId == categoryId &&
                data.catelogName == "水果" &&
                dateString >= "18:00" &&
                dateString <=  orderDateTime {
                return true
            }
        }
        return false
    }

    // 通过一级categoryId判定是否需要显示暂停销售提示
    public func shouldShowSuspendSalePrompt(levelTwo categoryId: String?) -> Bool {
        guard let categoryId = categoryId else {
            return false
        }
        let dateString = Date().format(to: "HH:mm")
        let orderDateTime = CityVModel.default.currentCity?.config?.orderDeadline ?? "21:00"
        for data in datas {
            if data.catelogName == "水果" {
                for sub in data.subs ?? [] {
                    if sub.catelogId == categoryId &&
                        dateString >= "18:00" &&
                        dateString <=  orderDateTime {
                        return true
                    }
                }
            }
        }
        return false
    }

}
