//
//  WithdrawVModel.swift
//  FBusiness
//
//

public class WithdrawVModel: BaseVModel {
    
    static public let `default` = WithdrawVModel()
    
    private var _currentWithdraw: [Float]?
    public var currentWithdraw: [Float]? {
        get {
            if _currentWithdraw == nil {
                if let data = local(URLPath.Config.withdraw, ["current": "withdraw"], to: [Float].self) {
                    _currentWithdraw = data
                }
            }
            return _currentWithdraw
        }
        set {
            _currentWithdraw = newValue
            if let _newValue = newValue {
                save(_newValue, URLPath.Config.withdraw, ["current": "withdraw"], from: [Float].self)
            }
        }
    }

    public func fetch(_ complection: ((_ error: HttpError?) -> Void)?) {
        cancel()
        get([Float].self, URLPath.Config.withdraw) { [weak self] (data, error) in
            if let data = data {
                self?.currentWithdraw = data
            }
            complection?(error)
        }
    }
}
