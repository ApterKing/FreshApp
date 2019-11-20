//
//  BaseVModel.swift
//  FBusiness
//
//

import UIKit
import RxSwift
import SwiftX
import Toaster

public class BaseVModel: NSObject {
    let bag = DisposeBag()
    var task: URLSessionTask?
    var shouldShowToastWhen500Upper = true
    
    internal func get<T: Decodable>(_ type: T.Type, _ path: String, _ params: Any? = nil, _ completion: @escaping (_ data: T?, _ error: HttpError?) -> Void) {
        request(type, path, .GET, params, nil, completion)
    }

    internal func head<T: Decodable>(_ type: T.Type, _ path: String, _ params: Any? = nil, _ completion: @escaping (_ data: T?, _ error: HttpError?) -> Void) {
        request(type, path, .HEAD, params, nil, completion)
    }
    
    internal func post<T: Decodable>(_ type: T.Type, _ path: String, _ params: Any? = nil, _ completion: @escaping (_ data: T?, _ error: HttpError?) -> Void) {
        request(type, path, .POST, params, nil, completion)
    }

    internal func put<T: Decodable>(_ type: T.Type, _ path: String, _ params: Any? = nil, _ completion: @escaping (_ data: T?, _ error: HttpError?) -> Void) {
        request(type, path, .PUT, params, nil, completion)
    }

    internal func delete<T: Decodable>(_ type: T.Type, _ path: String, _ params: Any? = nil, _ completion: @escaping (_ data: T?, _ error: HttpError?) -> Void) {
        request(type, path, .DELETE, params, nil, completion)
    }

    internal func options<T: Decodable>(_ type: T.Type, _ path: String, _ params: Any? = nil, _ completion: @escaping (_ data: T?, _ error: HttpError?) -> Void) {
        request(type, path, .OPTIONS, params, nil, completion)
    }

    internal func trace<T: Decodable>(_ type: T.Type, _ path: String, _ params: Any? = nil, _ completion: @escaping (_ data: T?, _ error: HttpError?) -> Void) {
        request(type, path, .TRACE, params, nil, completion)
    }

    internal func patch<T: Decodable>(_ type: T.Type, _ path: String, _ params: Any? = nil, _ completion: @escaping (_ data: T?, _ error: HttpError?) -> Void) {
        request(type, path, .PATCH, params, nil, completion)
    }
    
    internal func request<T: Decodable>(_ type: T.Type, _ path: String, _ method: XHttp.Method = .GET, _ params: Any?, _ configuration: XHttp.Configuration? = nil, _ completion: @escaping ((_ data: T?, _ error: HttpError?) -> Void)) {
        task = HttpClient.request(type, path, method, params, nil, { [weak self] (t, error) in
            guard let weakSelf = self else { return }
            if let err = error {
                if (err == .error500 || err == .errorOther) && weakSelf.shouldShowToastWhen500Upper {
                    weakSelf.shouldShowToastWhen500Upper = false
                    Toast.show(err.localizedDescription)
                }
            }
            completion(t, error)
        })
    }
    
    internal func multiUpload<T: Decodable>(_ type: T.Type, _ path: String, _ params: [AnyHashable: Any]?, _ multiParts: [XHttp.Uploader.MultiPart]?, _ completion: @escaping ((_ data: T?, _ error: HttpError?) -> Void)) {
        task = HttpClient.multiUpload(type, path, params, multiParts: multiParts, { [weak self] (t, error) in
            guard let weakSelf = self else { return }
            if let err = error {
                if (err == .error500 || err == .errorOther) && weakSelf.shouldShowToastWhen500Upper {
                    weakSelf.shouldShowToastWhen500Upper = false
                    Toast.show(err.localizedDescription)
                }
            }
            completion(t, error)
        })
    }
    
    // 获取缓存数据
    internal func local<T: Decodable>(_ path: String, _ params: Any?, to type: T.Type) -> T? {
        var key = path
        if let jsonParams = params, let jsonString = JSONSerialization.string(with: jsonParams) {
            key += jsonString
        }
        return try? XCache.default.object(forKey: key, to: type)
    }
    
    // 存储数据
    internal func save<T: Encodable>(_ data: T, _ path: String, _ params: Any?, from type: T.Type) {
        var key = path
        if let jsonParams = params, let jsonString = JSONSerialization.string(with: jsonParams) {
            key += jsonString
        }
        try? XCache.default.setObject(data, forKey: key, from: type, expiry: .never)
    }
    
    // 移除缓存数据
    internal func remove(_ path: String, _ params: Any?) {
        var key = path
        if let jsonParams = params, let jsonString = JSONSerialization.string(with: jsonParams) {
            key += jsonString
        }
        try? XCache.default.removeObject(forKey: key)
    }
    
    public func cancel() {
        if task?.state == URLSessionTask.State.running || task?.state == URLSessionTask.State.suspended {
            task?.cancel()
            task = nil
        }
    }
    
    deinit {
        cancel()
    }
}
