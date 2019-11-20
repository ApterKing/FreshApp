//
//  CarVModel.swift
//  FBusiness
//
//

import RxSwift
import RxCocoa
import Toaster

public class CarVModel: BaseVModel {
    
    static public let `default` = CarVModel()
    
    public var datas: BehaviorRelay<[CarModel]> = BehaviorRelay<[CarModel]>(value: [])
    
    public var isCheckedAll: Bool {
        get {
            guard datas.value.count != 0 else { return false }
            
            let allModels = datas.value.filter { (model) -> Bool in
                return model.productStatus ?? .normal == .normal && model.stock ?? 0 != 0
            }
            let filteredModels = checkedDatas(true)
            
            print("fuck  isCheckedAll   \(allModels.count)   \(filteredModels)")
            return allModels.count != 0 && allModels.count == filteredModels.count
        }
    }
    
    public func checkedDatas(_ shouldFilterSoltOut: Bool = true) -> [CarModel] {
        return datas.value.filter({ (model) -> Bool in
            let checked = model.isChecked ?? false
            if shouldFilterSoltOut {
                return (model.productStatus ?? .normal == .normal) && (model.stock ?? 0) != 0 && checked
            }
            return checked
        })
    }
    
    public func checkedCount(_ shouldFilterSoltOut: Bool = true) -> Int {
        var count = 0
        let datas = checkedDatas(shouldFilterSoltOut)
        for model in datas {
            count += model.count
        }
        return count
    }
    
    public func checkedOrgPrice(_ shouldFilterSoltOut: Bool = true) -> Float {
        guard datas.value.count != 0 else { return 0 }
        let checkModels = checkedDatas(shouldFilterSoltOut).reversed()
        var price: Float = 0
        for model in checkModels {
            price += (model.productPrice ?? 0) * Float(model.count)
        }
        return price
    }
    
    
    public func checkedPrice(_ shouldFilterSoltOut: Bool = true) -> Float {
        guard datas.value.count != 0 else { return 0 }
        
        // 选中的商品，排除掉库存不足
        let checkModels = checkedDatas(shouldFilterSoltOut).reversed()

        var price: Float = 0
        var hasSpecial: Bool = false  // 是否已经计算过特价商品

        for model in checkModels {
            // 优先判定特价，price为计算过特价，并且此商品为特价，那么先计算特价
            if !hasSpecial && model.productType == ProductModel.ProductType.specialPrice.rawValue  {
                price += model.productSpecialPrice ?? 0    // 特价 仅一个
                hasSpecial = true    // 设置为计算中已包含1件特价商品
                
                // 计算余下的商品
                price += _calculatePrice(model, max(0, model.count - 1))
            } else {
                price += _calculatePrice(model, model.count)
            }
        }
        return price
    }
    
    // 按照 专属 > 分类 > 普通 计算价格 (count 为指定数量，而不用购物车 model中数量，因为要排除特价)
    private func _calculatePrice(_ model: CarModel, _ count: Int) -> Float {
        guard let pcatelogId = model.pCatelogId else { return (model.productDiscountPrice ?? 0) * Float(count) }
        
        // 优惠列表数据 （取一级分类）
        let categories = CategoryVModel.default.datas.filter { (model) -> Bool in
            return model.config != nil
        }
        let categoryIds = categories.map { (model) -> String in
            return model.catelogId
        }
        
        // 我的专属优惠列表（一级分类）
        let discounts = UserVModel.default.currentUser?.config?.discounts ?? []
        let discountIds = discounts.map { (discount) -> String in
            return discount.catelogId
        }
        
        // 计算
        var price: Float = 0
        if discountIds.contains(pcatelogId) {   // 判定是否有专属优惠
            for discount in discounts {
                if discount.catelogId == pcatelogId, let discountRate = discount.discount {
                    price += (model.productDiscountPrice ?? 0) * discountRate * Float(count)
                    break
                }
            }
        } else if categoryIds.contains(pcatelogId) {   // 判定是否有分类折扣
            for category in categories {
                if category.catelogId == pcatelogId, let discountRate = category.config?.discount {
                    price += (model.productDiscountPrice ?? 0) * discountRate * Float(count)
                    break
                }
            }
        } else {  // 按照普通的计价
            price += (model.productDiscountPrice ?? 0) * Float(count)
        }
        return price
    }

    public func model(for productId: String) -> CarModel? {
        for model in datas.value {
            if model.productId == productId {
                return model
            }
        }
        return nil
    }
    
    public func checkStock(product: ProductModel, complection: ((_ success: Bool) -> Void)?) {
        if let carModel = CarVModel.default.model(for: product.productId) {
            guard (carModel.stock ?? 0) > carModel.count && carModel.productStatus ?? .normal == .normal else {
                Toast.show("库存不足")
                complection?(false)
                return
            }
        }
        complection?(true)
    }
    
    public func checkStock(carModel: CarModel, complection: ((_ success: Bool) -> Void)?) {
        guard (carModel.stock ?? 0) > carModel.count && carModel.productStatus ?? .normal == .normal else {
            Toast.show("库存不足")
            complection?(false)
            return
        }
        complection?(true)
    }
    
    public func add(_ productId: String, _ count: Int, _ shouldRefresh: Bool = true, _ showToast: Bool = true, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)? = nil) {
        
        let params: [AnyHashable: Any] = [
            "productId": productId,
            "count": count
        ]
        post(BaseModel.self, URLPath.Car.add, params) { [weak self] (model, error) in
            if shouldRefresh && error == nil {
                if showToast {
                    Toast.show("添加成功")
                }
                self?.fetch(nil)
            }
            complection?(model, error)
        }
    }
    
    public func edit(_ cartInfo: [String: Int], _ shouldRefresh: Bool = true, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)? = nil) {
        if let jsonCartInfo = (try? JSONSerialization.string(with: cartInfo)) as? String  {
            let params: [AnyHashable: Any] = [
                "cartInfo": jsonCartInfo,
            ]
            post(BaseModel.self, URLPath.Car.edit, params) { [weak self] (model, error) in
                if shouldRefresh && error == nil {
                    self?.fetch(nil)
                }
                complection?(model, error)
            }
        }
    }
    
    public func delete(_ cartIds: [String], _ shouldRefresh: Bool = true, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)? = nil) {
        if cartIds.count != 0, let jsonCartIds = (try? JSONSerialization.string(with: cartIds)) as? String {
            let params: [AnyHashable: Any] = [
                "cartIds": jsonCartIds,
            ]
            post(BaseModel.self, URLPath.Car.delete, params) { [weak self] (model, error) in
                if shouldRefresh && error == nil {
                    self?.fetch(nil)
                }
                complection?(model, error)
            }
        }
    }
    
    public func fetch(_ complection: ((_ error: HttpError?) -> Void)?) {
        get([CarModel].self, URLPath.Car.list, nil) { [weak self] (data, error) in
            if let results = data {

                // 重置上次选中包含售罄和时间之外的数据
                let tmpDatas = self?.datas.value.map({ (model) -> CarModel in
                    if model.isChecked == true {
                        model.isChecked = !CategoryVModel.default.shouldShowSuspendSalePrompt(levelOne: model.pCatelogId) && (model.stock ?? 0) > model.count && model.productStatus ?? .normal == .normal
                    }
                    return model
                })
                self?.datas.accept(tmpDatas ?? [])

                // 上一次已选中
                var checkedIds: [String] = []
                if let datas = self?.datas.value {
                    checkedIds = datas.filter({ (model) -> Bool in
                        return model.isChecked ?? false
                    }).map({ (model) -> String  in
                        return model.cartId
                    })
                }
                // 上一次包含的Id，如果这次的id 不在上一次的id当中，那么则设置为选中
                let lastIds = self?.datas.value.map({ (model) -> String in
                    return model.cartId
                }) ?? []
                
                var datas = [CarModel]()
                for data in results {
                    if checkedIds.contains(data.cartId) {
                        data.isChecked = true
                    }
                    if !lastIds.contains(data.cartId) {
                        data.isChecked = !CategoryVModel.default.shouldShowSuspendSaleHeaderPrompt(levelOne: data.pCatelogId) && (data.stock ?? 0) > data.count && data.productStatus ?? .normal == .normal
                    }
                    datas.append(data)
                }
                self?.datas.accept(datas)
            }
            
            if error == HttpError.error204 {
                self?.datas.accept([])
            }
            complection?(error)
        }
    }

}
