//
//  UserVModel.swift
//  FBusiness
//
//

import SwiftX

// 管理与用户相关的所有数据
public class UserVModel: BaseVModel {
    
    public typealias VerifyHandler = ((_ success: Bool) -> Void)
    

    static public let `default` = UserVModel()
    
    public var isLogined: Bool {
        return currentToken != nil
    }
    
    private var _currentUser: UserModel?
    public var currentUser: UserModel? {
        get {
            if _currentUser == nil {
                if let user = local(URLPath.User.userInfo, ["current": "user"], to: UserModel.self) {
                    _currentUser = user
                }
            }
            return _currentUser
        }
        set {
            _currentUser = newValue
            if let _newValue = newValue {
                save(_newValue, URLPath.User.userInfo, ["current": "user"], from: UserModel.self)
            } else {
                remove(URLPath.User.userInfo, ["current": "user"])
            }
            NotificationCenter.default.post(name: Constants.notification_userInfo_changed, object: nil)
        }
    }
    
    private var _currentToken: TokenModel?
    public var currentToken: TokenModel? {
        get {
            if _currentToken == nil {
                if let token = local(URLPath.User.login, ["current": "token"], to: TokenModel.self) {
                    _currentToken = token
                }
            }
            return _currentToken
        }
        set {
            _currentToken = newValue
            if let _newValue = newValue {
                save(_newValue, URLPath.User.login, ["current": "token"], from: TokenModel.self)
            }
        }
    }
    
    private var _currentAddress: AddressModel?
    public var currentAddress: AddressModel? {
        get {
            if _currentAddress == nil {
                if let address = local(URLPath.User.addressList, ["current": "address"], to: AddressModel.self) {
                    _currentAddress = address
                }
            }
            return _currentAddress
        }
        set {
            _currentAddress = newValue
            if let _newValue = newValue {
                save(_newValue, URLPath.User.addressList, ["current": "address"], from: AddressModel.self)
            } else {
                remove(URLPath.User.addressList, ["current": "address"])
            }
        }
    }
    
}

public extension UserVModel {
    
    // 验证是否登录
    public func verify(_ handler: VerifyHandler?) {
        if currentToken != nil {
            handler?(true)
        } else {
            #if FRESH_CLIENT
            LoginViewController.show(handler)
            #endif
        }
    }
    
    // 仅仅刷新用户信息
    public func userInfoRefresh(_ complection: ((_ user: UserModel?, _ error: HttpError?) -> Void)?) {
        #if FRESH_CLIENT
        guard isLogined else { return }
        get(UserModel.self, URLPath.User.userInfo, nil) { [weak self] (data, error) in
            if let data = data {
                self?._currentUser = data
            }
            complection?(data, error)
        }
        #endif
    }
    
    public func userInfo(_ complection: ((_ user: UserModel?, _ error: HttpError?) -> Void)?) {
        cancel()

        #if FRESH_CLIENT
        // 同步地址
        AddressVModel.default.fetch(nil)
        
        // 同步购物车
        CarVModel.default.fetch(nil)

        // 同步用户信息
        get(UserModel.self, URLPath.User.userInfo, nil) { [weak self] (data, error) in
            if let weakSelf = self, let data = data {
                weakSelf._currentUser = data
                weakSelf.save(data, URLPath.User.userInfo, ["current": "user"], from: UserModel.self)
                
                NotificationCenter.default.post(name: Constants.notification_userInfo_changed, object: nil)
                
                XJPush.default.setAlias(UserVModel.default.currentToken?.userId ?? "", { (iResCode, iAlias, seq) in
                    print("XJPush   userInfo  set  Alias   \(iResCode)    \(String(describing: iAlias))   \(seq)" as Any)
                })
            } else {
                self?.shouldShowToastWhen500Upper = false
                // 保证一定获取到用户信息
//                if error != HttpError.error401 {
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: { [weak self] () in
//                        self?.userInfo(complection)
//                    })
//                }
            }
            complection?(data, error)
        }
        #else
        // 同步配送端用户信息
        get(UserModel.self, URLPath.Delivery.userInfo, nil) { [weak self] (data, error) in
            if let weakSelf = self, let data = data {
                weakSelf._currentUser = data
                weakSelf.save(data, URLPath.User.userInfo, ["current": "user"], from: UserModel.self)
            } else {

                // 保证一定获取到用户信息
                if error != HttpError.error401 {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: { [weak self] () in
                        self?.userInfo(complection)
                    })
                }
            }
            complection?(data, error)
        }
        #endif
    }
    
    public func logout() {
        _currentUser = nil
        remove(URLPath.User.userInfo, ["current": "user"])
        NotificationCenter.default.post(name: Constants.notification_userInfo_changed, object: nil)
        NotificationCenter.default.post(name: Constants.notification_user_logout, object: nil)

        _currentToken = nil
        remove(URLPath.User.login, ["current": "token"])
        
        CarVModel.default.datas.accept([])
        
        AddressVModel.default.currentAddress = nil
        AddressVModel.default.datas.removeAll()
        
        #if FRESH_CLIENT
        XJPush.default.deleteAlias(nil)
        #endif
    }
}
