//
//  CommissionVModel.swift
//  FBusiness
//
//

// 用户邀请佣金设置
public class CommissionVModel: BaseVModel {
    
    public var data: CommissionModel?
    
    static public let `default` = CommissionVModel()
    
    private var _currentCommission: CommissionModel?
    public var currentCommission: CommissionModel? {
        get {
            if _currentCommission == nil {
                if let data = local(URLPath.Config.commission, ["current": "commisstion"], to: CommissionModel.self) {
                    _currentCommission = data
                }
            }
            return _currentCommission
        }
        set {
            _currentCommission = newValue
            if let _newValue = newValue {
                save(_newValue, URLPath.Config.commission, ["current": "commisstion"], from: CommissionModel.self)
            }
        }
    }
    
    public func fetch(_ complection: ((_ error: HttpError?) -> Void)?) {
        cancel()
        get(CommissionModel.self, URLPath.Config.commission) { [weak self] (data, error) in
            if let data = data {
                self?.currentCommission = data
            }
            complection?(error)
        }
    }

}
