//
//  GoodsVModel.swift
//  FBusiness
//
//

class GoodsVModel: BaseVModel {
    
    func fetch(_ productId: String, complection: ((_ data: ProductModel?, _ error: HttpError?) -> Void)?) {
        let params = [
            "productId": productId
        ]
        get(ProductModel.self, URLPath.Product.detail, params) { (data, error) in
            complection?(data, error)
        }
    }

    func fetchDeliveryTime(_ complection: ((_ data: DeliveryTimeModel?, _ error: HttpError?) -> Void)? = nil) {
        let params: [AnyHashable: Any] = [
            "cityId": CityVModel.default.currentCityCode,
            "deliverDate": Date().format(to: "yyyy-MM-dd")
        ]
        get([DeliveryTimeModel].self, URLPath.Config.deliverConfig, params) { (data, error) in
            if let models = data, models.count != 0 {
                complection?(models.first, error)
            } else {
                complection?(nil, error)
            }
        }
    }
}
