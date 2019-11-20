//
//  Bundle+current.swift
//  FBusiness
//
//

import UIKit

extension Bundle {
    
    static var currentCommon: Bundle {
        get {
            return Bundle(for: GoodsDetailViewController.self)
        }
    }
    
}
