//
//  Config+D.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/25.
//

import SwiftX
import Toaster

public class DConfig: NSObject {
    
    static public let `default` = DConfig()
    
    public func configAll(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        configHttp()
        configOpenSDK(launchOptions: launchOptions)
        syncAll()
        
        Toast.setupKeyboardVisibleManager()
    }
    
    // 配置http请求
    public func configHttp() {
        HttpClient.configClient(with: URLPath.host)
    }
    
    // 配置百度地图
    public func configOpenSDK(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        XLocationManager.default.checkPermision("4WEp7WPSBBvU9ZiBhGDfGRI2LCSESay4")
        XLocationManager.default.startUpdatingLocation { (info, error) in
            if let info = info {
                print("OpenSDK  baidu   \(info.city)    \(info.cityCode)  \(info.adCode)")
                UserDefaults.standard.set(info.city, forKey: Constants.current_loc_city)
                UserDefaults.standard.set(info.adCode, forKey: Constants.current_loc_city_code)
            }
        }
        XBMKMapManager.default.start("4WEp7WPSBBvU9ZiBhGDfGRI2LCSESay4")
    }
    
    public func syncAll() {
        UserVModel.default.verify { (success) in
            if success {
                UserVModel.default.userInfo(nil)
            } else {
                UserVModel.default.logout()
            }
        }
    }
    
}
