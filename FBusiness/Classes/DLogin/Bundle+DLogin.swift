//
//  Bundle+current.swift
//  FBusiness
//
//  Created by wangcong on 2019/2/16.
//

import UIKit

public extension Bundle {
    
    static var currentDLogin: Bundle {
        get {
            return Bundle(for: DLoginViewController.self)
        }
    }
    
}
