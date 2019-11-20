//
//  CityVModel.swift
//  FBusiness
//
//

public class CityVModel: BaseVModel {
    
    static public let `default` = CityVModel()
    
    public var datas: [CityModel] = []

    private var _currentCity: CityModel?
    public var currentCity: CityModel? {
        get {
            if _currentCity == nil {
                if let city = local(URLPath.Config.cities, ["current": "city"], to: CityModel.self) {
                    _currentCity = city
                }
            }
            return _currentCity
        }
        set {
            if let _newValue = newValue {
                save(_newValue, URLPath.Config.cities, ["current": "city"], from: CityModel.self)
                UserDefaults.standard.set(_newValue.cityName, forKey: Constants.current_loc_city)
                UserDefaults.standard.set(_newValue.cityCode, forKey: Constants.current_loc_city_code)

                let latestCity = _currentCity
                _currentCity = newValue
                if latestCity?.cityCode != newValue?.cityCode {
                    ConfigVModel.default.fetch(.startup, nil)
                    NotificationCenter.default.post(name: Constants.notification_city_changed, object: nil)
                }

            }
        }
    }
    
    public var currentCityName: String {
        return currentCity?.cityName ?? currentLocCity
    }
    
    public var currentCityCode: String {
        return currentCity?.cityCode ?? currentLocCityCode
    }

    public var currentLocCityCode: String {
        get {
            return UserDefaults.standard.string(forKey: Constants.current_loc_city_code) ?? "510900"
        }
    }
    
    public var currentLocCity: String {
        get {
            return UserDefaults.standard.string(forKey: Constants.current_loc_city) ?? "遂宁市"
        }
    }
    
}

extension CityVModel {
    
    public func fetch(_ complection: ((_ error: HttpError?) -> Void)?) {
        let params = [
            "isOpen": "yes",
        ]
        if let data = local(URLPath.Config.cities, params, to: [CityModel].self) {
            datas = data
            complection?(nil)
        }
        
        cancel()
        get([CityModel].self, URLPath.Config.cities, params) { [weak self] (data, error) in
            if let weakSelf = self, let data = data {
                weakSelf.datas = data
                weakSelf._process(data)
                weakSelf.save(data, URLPath.Config.cities, params, from: [CityModel].self)
            }
            complection?(error)
        }
    }
    
    private func _process(_ datas: [CityModel]) {
        if datas.count != 0 {
            if currentCity == nil {
                currentCity = datas[0]
            } else {
                let cityIds = datas.map { (model) -> String in
                    return model.cityId
                }
                if cityIds.contains(currentCity!.cityId) {
                    for city in datas {
                        if city.cityCode == currentLocCityCode {
                            currentCity = city
                            break
                        }
                    }
                } else {
                    currentCity = datas[0]
                }
            }
        }
    }

}
