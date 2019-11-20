//
//  AddressVModel.swift
//  FBusiness
//
//


public class AddressVModel: BaseVModel {
    
    static public let AddressChangeNotification = Notification.Name(rawValue: "AddressChangeNotification")
    
    static public let `default` = AddressVModel()
    
    public var datas: [AddressModel] = []

    private var _currentAddress: AddressModel?
    public var currentAddress: AddressModel? {
        get {
            if _currentAddress == nil {
                if let address = local(URLPath.User.addressList, ["current": "address", "userId": UserVModel.default.currentUser?.userId ?? ""], to: AddressModel.self) {
                    _currentAddress = address
                }
            }
            return _currentAddress
        }
        set {
            _currentAddress = newValue
            if let _newValue = newValue {
                save(_newValue, URLPath.User.addressList, ["current": "address", "userId": UserVModel.default.currentUser?.userId ?? ""], from: AddressModel.self)
            } else {
                remove(URLPath.User.addressList, ["current": "address", "userId": UserVModel.default.currentUser?.userId ?? ""])
            }
        }
    }
    
}

extension AddressVModel {
    
    public func fetch(_ complection: ((_ error: HttpError?) -> Void)?) {
        cancel()
        get([AddressModel].self, URLPath.User.addressList, nil) { [weak self] (data, error) in
            guard let weakSelf = self else { return }
            if let data = data {
                weakSelf.datas = data
                
                if weakSelf.currentAddress == nil {
                    for model in weakSelf.datas {
                        if model.isDefault == "yes" {
                            weakSelf.currentAddress = model
                            break
                        }
                    }
                    if weakSelf.currentAddress == nil, weakSelf.datas.count != 0 {
                        weakSelf.currentAddress = weakSelf.datas[0]
                    }
                } else {
                    let addressIds = data.map({ (model) -> String in
                        return model.addressId ?? ""
                    })
                    if !addressIds.contains(weakSelf.currentAddress!.addressId ?? "") {
                        for model in weakSelf.datas {
                            if model.isDefault == "yes" {
                                weakSelf.currentAddress = model
                                break
                            }
                        }

                        if weakSelf.currentAddress == nil, weakSelf.datas.count != 0 {
                            weakSelf.currentAddress = weakSelf.datas[0]
                        }
                    }
                }
            } else if error == HttpError.error204 || error == HttpError.errorNull {
                weakSelf.currentAddress = nil
                weakSelf.datas = []
            }
            complection?(error)
        }
    }
    
    public func add(_ addressModel: AddressModel, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)?) {
        
        if let data = try? JSONEncoder().encode(addressModel), let params = JSONSerialization.object(with: data) {
            cancel()
            
            post(BaseModel.self, URLPath.User.addressSubmit, params) { (model, error) in
                complection?(model, error)
            }
        }
    }
    
    public func delete(_ addressId: String, _ complection: ((_ model: BaseModel?, _ error: HttpError?) -> Void)?) {
        post(BaseModel.self, URLPath.User.addressDelete, ["addressId": addressId]) { (model, error) in
            if AddressVModel.default.currentAddress?.addressId == addressId {
                AddressVModel.default.currentAddress = nil
            }
            complection?(model, error)
        }
    }
    
}
