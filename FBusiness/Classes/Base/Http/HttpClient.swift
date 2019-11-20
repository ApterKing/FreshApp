//
//  HttpClient.swift
//  FBusiness
//
//

import Foundation
import RxSwift
import SwiftX
import Toaster
import RxCocoa

public class HttpClient: NSObject {
    static public func configClient(with host: String) {
        var configuration = XHttp.Configuration.defaultConfiguration
        configuration.requestSerializer = .query
        configuration.responseSerializer = .json
        XHttp.Configuration.defaultConfiguration = configuration
    }
}

// MARK: 回调请求方式
public extension HttpClient {
    
    static public func request<T: Decodable>(_ type: T.Type, _ path: String, _ method: XHttp.Method = .GET, _ params: Any?, _ configuration: XHttp.Configuration? = nil, _ completion: @escaping ((_ data: T?, _ error: HttpError?) -> Void)) -> URLSessionTask? {
        var requestParams = [AnyHashable: Any]()
        if let params = params as? [AnyHashable: Any] {
            requestParams = params
        }
        if let token = UserVModel.default.currentToken?.token {
            requestParams["token"] = token
        }
        if let userId = UserVModel.default.currentToken?.userId {
            requestParams["userId"] = userId
        }
        return XHttp.request(path, method, .query, requestParams, configuration, { (result) in
            switch result {
            case .success(let data):
                let parsed = HttpClient.parse(data: data, to: type)
                completion(parsed.data, parsed.error)
            case .failure(let error):
                print("HttpCleint    Request  failure   \(String(describing: error))")
                let error = error as NSError
                if error.code == HttpError.errorTimeout.code {
                    _toast(HttpError.errorTimeout.localizedDescription)
                    completion(nil, HttpError.errorTimeout)
                } else if error.code == HttpError.errorNetOffline.code {
                    _toast(HttpError.errorNetOffline.localizedDescription)
                    completion(nil, HttpError.errorNetOffline)
                } else if error.code == HttpError.errorCanceled.code {
                    completion(nil, HttpError.errorCanceled)
                } else if error.code == HttpError.errorOther.code {
                    completion(nil, HttpError.errorOther)
                } else {
                    completion(nil, HttpError.error500)
                }
            }
        })
    }
    
    static public func multiUpload<T: Decodable>(_ type: T.Type, _ path: String, _ params: [AnyHashable: Any]? = nil, multiParts: [XHttp.Uploader.MultiPart]? = nil, _ completion: @escaping ((_ data: T?, _ error: HttpError?) -> Void)) -> URLSessionTask? {
        var requestParams = [AnyHashable: Any]()
        if let params = params {
            requestParams = params
        }
        if let token = UserVModel.default.currentToken?.token {
            requestParams["token"] = token
        }
        if let userId = UserVModel.default.currentToken?.userId {
            requestParams["userId"] = userId
        }
        if CityVModel.default.currentCity != nil {
            requestParams["cityId"] = CityVModel.default.currentCityCode
        }
        guard let url = URL(string: path.hasPrefix("http") ? path : "\(XHttp.Configuration.defaultConfiguration.host ?? "")" + path) else { return nil }
        return XHttp.Uploader.multiUploadTask(with: url, formParams: requestParams, multiParts: multiParts, handler: { (result) in
            switch result {
            case .progress(_, _):
                break
            case .success(let data):
                let parsed = HttpClient.parse(data: data, to: type)
                completion(parsed.data, parsed.error)
            case .failure(let error):
                print("HttpCleint    multiUpload  failure   \(String(describing: error))")
                let error = error as NSError
                if error.code == HttpError.errorTimeout.code {
                    _toast(HttpError.errorTimeout.localizedDescription)
                    completion(nil, HttpError.errorTimeout)
                } else if error.code == HttpError.errorNetOffline.code {
                    _toast(HttpError.errorNetOffline.localizedDescription)
                    completion(nil, HttpError.errorCanceled)
                } else if error.code == HttpError.errorCanceled.code {
                    completion(nil, HttpError.errorCanceled)
                } else if error.code == HttpError.errorOther.code {
                    completion(nil, HttpError.errorOther)
                } else {
                    completion(nil, HttpError.error500)
                }
            }
        })
    }
    
}

// MARK: Rx请求方式
public extension HttpClient {
    
    final public class Rx {
        
//        static public func request<T: Decodable>(_ type: T.Type, _ path: String, _ method: XHttp.Method = .GET, _ params: Any?, _ configuration: XHttp.Configuration = XHttp.Configuration.defaultConfiguration) -> Observable<T> {
//            return Observable<T>.create({ (observer) -> Disposable in
//                let disposable = XHttp.Rx.request(path, method, .query, params, configuration).subscribe(onNext: { (data) in
//                    let parsed = HttpClient.parse(data: data, to: type)
//                    if parsed.error != nil {
//                        observer.onError(parsed.error!)
//                    } else {
//                        observer.onNext(parsed.data!)
//                        observer.onCompleted()
//                    }
//                }, onError: { (error) in
//                    let error = error as NSError
//                    if error.code == HttpError.errorTimeout.code {
//                        _toast(HttpError.errorTimeout.localizedDescription)
//                        observer.onError(HttpError.errorTimeout)
//                    } else if error.code == HttpError.errorNetOffline.code {
//                        _toast(HttpError.errorNetOffline.localizedDescription)
//                        observer.onError(HttpError.errorTimeout)
//                    } else if error.code == HttpError.errorCanceled.code {
//                        observer.onError(HttpError.errorCanceled)
//                    } else if error.code == HttpError.errorOther.code {
//                        observer.onError(HttpError.errorOther)
//                    } else {
//                        observer.onError(HttpError.error500)
//                    }
//                }, onCompleted: nil, onDisposed: nil)
//                return Disposables.create {
//                    disposable.dispose()
//                }
//            })
//        }

    }
    
}

/// MARK: 依据业务解析数据
fileprivate extension HttpClient {
    
    static func parse<T>(data: Any, to type: T.Type) -> (data: T?, error: HttpError?) where T : Decodable {
        do {
            // 统一处理返回的数据 code
            let rModel = try JSONDecoder.decode(BaseModel.self, from: data)
            guard rModel.code == HttpError.error200.code else {
                switch rModel.code {
                case HttpError.error204.code:
//                    _toast(rModel.msg)
                    return (nil, HttpError.error204)
                case HttpError.error400.code:
                    _toast(rModel.msg)
                    #if FRESH_CLIENT
                    if rModel.msg?.contains("此用户已被禁用") ?? false {
                        UserVModel.default.logout()
                        LoginViewController.show()
                    }
                    #endif
                    return (nil, HttpError.error400)
                case HttpError.error401.code:
                    _toast(rModel.msg)
                    #if FRESH_CLIENT
                    UserVModel.default.logout()
                    LoginViewController.show()
                    #else
                    UIApplication.shared.keyWindow?.rootViewController = XBaseNavigationController(rootViewController: DLoginViewController(nibName: "DLoginViewController", bundle: Bundle.currentDLogin))
                    #endif
                    return (nil, HttpError.error401)
                case HttpError.error402.code:
                    return (nil, HttpError.error402)
                case HttpError.error404.code:
                    return (nil, HttpError.error404)
                case HttpError.errorJSONDecoder.code:
                    _toast(HttpError.errorJSONDecoder.localizedDescription)
                    return (nil, HttpError.errorJSONDecoder)
                default:
                    return (nil, HttpError.error500)
                }
            }
            
            if type != BaseModel.self, let object = data as? [AnyHashable: Any] {
                if object["response"] is NSNull {
                    return (nil, HttpError.errorNull)
                } else {
                    do {
                        let model = try JSONDecoder.decode(T.self, from: data, forKey: "response")
                        return (model, nil)
                    } catch let error {
                        print("Http  prase  \(String(describing: error))")
                        return (nil, HttpError.errorJSONDecoder)
                    }
                }
            } else {
                let model = try JSONDecoder.decode(T.self, from: data)
                return (model, nil)
            }
        } catch {
            return (nil, HttpError.errorOther)
        }
    }
    
    static private func _toast(_ message: String?) {
        Toast.show(message)
    }
}

public enum HttpError: Error {
    case error200           // 无错误
    case error204           // 请求成功但是无内容
    case error400           // 错误的请求
    case error401           // 未授权需要登录
    case error402           // 登录失败或者用户未注册
    case error404           // 请求地址不存在
    case error500           // 系统错误
    case errorOther         // 无法连接服务器
    case errorNull          // 服务端将[] 数据返回为null统一处理
    
    // 本地
    case errorJSONDecoder       // 解析错误
    case errorNetOffline        // 网络连接错误
    case errorTimeout           // 网络不可达
    case errorCanceled          // 取消
    
    public var code: Int {
        switch self {
        case .error200:
            return 200
        case .error204:
            return 204
        case .error400:
            return 400
        case .error401:
            return 401
        case .error402:
            return 402
        case .error404:
            return 404
        case .error500:
            return 500
        case .errorNull:
            return -Int.max
        case .errorOther:
            return -1004
        case .errorJSONDecoder:
            return -2
        case .errorNetOffline:
            return -1009
        case .errorTimeout:
            return -1001
        case .errorCanceled:
            return -999
        }
    }
    
    public var localizedDescription: String {
        switch self {
        case .error200:
            return "无错误"
        case .error204:
            return "请求成功但是无内容"
        case .error400:
            return "错误的请求"
        case .error401:
            return "未授权需要登录"
        case .error402:
            return "登录失败或者用户未注册"
        case .error404:
            return "请求地址不存在"
        case .error500:
            return "系统错误"
        case .errorNull:
            return "服务端未按照规定格式返回数据"
        case .errorOther:
            return "服务器连接错误"
        case .errorJSONDecoder:
            return "服务端返回数据格式错误"
        case .errorNetOffline:
            return "网络连接断开，请检查您是否已联网"
        case .errorTimeout:
            return "连接超时，请检查网络设置"
        case .errorCanceled:
            return "取消请求"
        }
    }
    
}
