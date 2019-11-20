//
//  UpdateVModel.swift
//  FBusiness
//
//

public class UpdateVModel: BaseVModel {
    
    public func fetch(_ completion:((_ model: UpdateModel?, _ error: HttpError?) -> Void)?) {
        #if FRESH_CLIENT
        let appType = UpdateModel.APPType.consumer
        #else
        let appType = UpdateModel.APPType.consumer
        #endif
        let params: [String: Any] = [
            "osType": "iOS",
            "versionNo": Bundle.bundleShortVersion ?? "1.0",
            "appType": appType
        ]
        get(UpdateModel.self, URLPath.Config.update, params) { (data, error) in
            completion?(data, error)
        }
    }

}
