//
//  CouponVModel.swift
//  FBusiness
//
//

public class CouponVModel: BaseVModel {
    
    public var datas: [CouponModel] = []
    public func fetch(_ couponType: CouponModel.CouponType? = nil, _ complection: ((_ error: HttpError?) -> Void)?) {
        var params: [AnyHashable: Any] = [:]
        if let type = couponType {
            params["couponType"] = type.rawValue
        }
        get([CouponModel].self, URLPath.User.coupons, params) { [weak self] (data, error) in
            guard let weakSelf = self else { return }
            if let data = data {
                weakSelf.datas = data
            }
            if error == HttpError.error204 {
                weakSelf.datas = []
            }
            complection?(nil)
        }
    }

}

extension CouponVModel {
    
    public func getCoupon(_ type: CouponModel.CouponType, complection: ((_ error: HttpError?) -> Void)?) {
        let params = [
            "type": type.rawValue
        ]
        post(BaseModel.self, URLPath.User.getCoupon, params) { (_, error) in
            complection?(error)
        }
    }
    
}
