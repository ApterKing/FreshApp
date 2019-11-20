//
//  Config.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster

public class Config: NSObject {
    
    static public let `default` = Config()
    
    public func configAll(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {

        configHttp()
        configJPUSH(launchOptions: launchOptions)
        syncAll()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] () in
            self?.configOpenSDK(launchOptions: launchOptions)
            Toast.setupKeyboardVisibleManager()
            

            AppVersion.check(bundleId: Bundle.bundleIdentifier ?? "com.xyd.fresh", delay: 5, showEmbedAlertViewController: true) { (info, error) in
                print("fuck   appversion  --- \(String(describing: info))")
            }
        }
    }
    
    // 配置http请求
    public func configHttp() {
        HttpClient.configClient(with: URLPath.host)
    }
    
    // config JPUSH （jpush需要单独启动的时候配置）
    public func configJPUSH(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        XJPush.default.register(appKey: "4bc3c038022e91850a159f93", launchOptions: launchOptions ?? [:]) { (registrationID) in
            // 推送注册成功
            if registrationID != nil {
                var iTags = Set<String>()
                iTags.insert("3xian")
                XJPush.default.setTags(iTags, { (iResCode: Int, iTags: Set<AnyHashable>?, seq: Int) in
                    print("XJPush  configOpenSDK   set tag   \(iResCode)    \(String(describing: iTags))   \(seq)" as Any)
                }, 0)
                
                if UserVModel.default.isLogined {
                    
                    XJPush.default.setAlias(UserVModel.default.currentToken?.userId ?? "", { (iResCode, iAlias, seq) in
                        print("XJPush   configOpenSDK  set Alias   \(iResCode)    \(String(describing: iAlias))   \(seq)" as Any)
                    })
                    
                }
            }
        }
        XJPush.default.setHandler(presentHandler: { (_, remote) in
            if remote {
                NotificationCenter.default.post(name: Constants.notification_order_status_changed, object: nil)
            }
        }) { (response, remote) in
            if remote {
                let userInfo = response.notification.request.content.userInfo
                if let orderId = userInfo["orderId"] as? String {  // 订单详情
                    if let orderType = userInfo["orderType"] as? String, orderType == "homeService" {
                        NotificationCenter.default.post(name: Constants.notification_order_home_status_changed, object: nil)
                        HouseKeepingContainer.show()
                    } else {
                        NotificationCenter.default.post(name: Constants.notification_order_status_changed, object: nil)
                        OrderDetailViewController.show(orderId)
                    }
                } else if let productId = userInfo["productId"] as? String {  // 商品详情
                    GoodsDetailViewController.show(with: productId)
                }
            }
        }
    }
    
    
    // 配置qq、微信、微博、支付宝
    public func configOpenSDK(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        XQQ.default.register(appKey: "1108393391")
        XWeChat.default.register(appKey: "wxcd21733fdc9c9581", appSecret: "30b54dbce3b446b8ff236468ec8e19d8")
        XWeibo.default.register(appKey: "4116540595")
        
        XLocationManager.default.checkPermision("Ev8u0tTe90FnKKzyLFil5CfKrssXx9xn")
        XLocationManager.default.startUpdatingLocation { (info, error) in
            if let info = info {
                print("OpenSDK    \(String(describing: info.city))    \(String(describing: info.cityCode))  \(String(describing: info.adCode))")
                UserDefaults.standard.set(info.city, forKey: Constants.current_loc_city)
                UserDefaults.standard.set(info.adCode, forKey: Constants.current_loc_city_code)
            }
        }
        XBMKMapManager.default.start("Ev8u0tTe90FnKKzyLFil5CfKrssXx9xn")
    }
    
    public func syncAll() {
        syncCagetory()
        syncCommission()
        syncWithdraw()
        syncCity()
        
        if UserVModel.default.isLogined {
            UserVModel.default.userInfo(nil)
        } else {
            UserVModel.default.logout()
        }
    }
    
    // 由于首页跳转需要使用，这里同步一下数据
    private func syncCagetory() {
        CategoryVModel.default.shouldShowToastWhen500Upper = false
        CategoryVModel.default.fetch { [weak self] (error) in
            if error != nil && error != HttpError.error204 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                    self?.syncCagetory()
                })
            }
        }
    }
    
    // 同步邀请佣金设置
    private func syncCommission() {
        CommissionVModel.default.shouldShowToastWhen500Upper = false
        CommissionVModel.default.fetch { [weak self] (error) in
            if error != nil && error != HttpError.error204 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                    self?.syncCommission()
                })
            }
        }
    }
    
    // 同步提现金额
    private func syncWithdraw() {
        WithdrawVModel.default.shouldShowToastWhen500Upper = false
        WithdrawVModel.default.fetch { [weak self] (error) in
            if error != nil && error != HttpError.error204 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                    self?.syncWithdraw()
                })
            }
        }
    }
    
    // 同步城市
    private func syncCity() {
        CityVModel.default.shouldShowToastWhen500Upper = false
        
        let launchs = ConfigVModel.default.currentLaunch
        if launchs.count != 0 {
            SplashViewController.show()
        }
        CityVModel.default.fetch({ [weak self] (error) in
            if error != nil && error != HttpError.error204 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                    self?.syncCity()
                })
            } else {
                if let _ = CityVModel.default.currentCity {
                    ConfigVModel.default.fetch(.startup) { (_, _) in
                        if launchs.count == 0 {
                            SplashViewController.show()
                        }
                    }
                }
            }
        })
    }
}


