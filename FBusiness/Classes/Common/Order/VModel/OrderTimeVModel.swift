//
//  OrderTimeVModel.swift
//  FBusiness
//
//


class OrderTimeVModel: BaseVModel {
    
    var tomorrowTimes: [DeliveryTimeModel] = []
    var afterTomorrowTimes: [DeliveryTimeModel] = []
    
    func fetch(_ complection: ((_ error: HttpError?) -> Void)? = nil) {
        var atomicCount = 0
        var atomicError: HttpError?
        
        // 取明天
        _fetch(Date().adding(Calendar.Component.day, value: 1).format(to: "yyyy-MM-dd")) { (error) in
            objc_sync_enter(atomicCount)
            atomicCount += 1
            objc_sync_exit(atomicCount)
            if error != nil {
                atomicError = error
            }
            if atomicCount == 2 {
                complection?(atomicError)
            }
        }
        
        // 取后天
        _fetch(Date().adding(Calendar.Component.day, value: 2).format(to: "yyyy-MM-dd")) { (error) in
            objc_sync_enter(atomicCount)
            atomicCount += 1
            objc_sync_exit(atomicCount)
            if error != nil {
                atomicError = error
            }
            if atomicCount == 2 {
                complection?(atomicError)
            }
        }
        
    }
    
    private func _fetch(_ dateString: String, _ complection: ((_ error: HttpError?) -> Void)? = nil) {
        let params: [AnyHashable: Any] = [
            "cityId": CityVModel.default.currentCityCode,
            "deliverDate": dateString
        ]
        get([DeliveryTimeModel].self, URLPath.Config.deliverConfig, params) { [weak self] (data, error) in
            if let models = data {
                self?._process(dateString, models)
            }
            complection?(error)
        }
    }
    
    private func _process(_ dateString: String, _ models: [DeliveryTimeModel]) {
        var results = models
        results.sort(by: { (model0, model1) -> Bool in
            return model0.deliverStartTime < model1.deliverStartTime
        })
        if dateString == Date().adding(Calendar.Component.day, value: 1).format(to: "yyyy-MM-dd") {
            tomorrowTimes.removeAll()
            tomorrowTimes.append(contentsOf: results)
        } else {
            afterTomorrowTimes.removeAll()
            afterTomorrowTimes.append(contentsOf: results)
        }
    }

}
