//
//  ConfigVModel.swift
//  FBusiness
//
//

import RxSwift
import RxCocoa

public class ConfigVModel: BaseVModel {
    
    static public let `default` = ConfigVModel()

    private var _currentLaunch: [ConfigModel] = []
    public var currentLaunchRelay = PublishRelay<[ConfigModel]>()
    public var currentLaunch: [ConfigModel] {
        get {
            if _currentLaunch.count == 0 {
                if let data = local(URLPath.Config.banner, ["current": "launch"], to: [ConfigModel].self) {
                    _currentLaunch = data
                }
            }
            return _currentLaunch
        }
        set {
            _currentLaunch = newValue
            currentLaunchRelay.accept(newValue)
            save(newValue, URLPath.Config.banner, ["current": "launch"], from: [ConfigModel].self)
        }
    }
    
    public func fetch(_ type: ConfigModel.ConfigType, _ complection: ((_ data: [ConfigModel], _ error: HttpError?) -> Void)?) {
        cancel()
        let params = [
            "configType": type.rawValue,
            "cityId": CityVModel.default.currentCityCode
        ]
        get([ConfigModel].self, URLPath.Config.banner, params) { [weak self] (data, error) in
            if let data = data {
                if type == ConfigModel.ConfigType.startup {
                    self?.currentLaunch = data
                }
            }
            complection?(data ?? [], error)
        }
    }

}
