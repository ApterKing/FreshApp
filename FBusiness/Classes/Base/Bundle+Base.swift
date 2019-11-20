//
//  Bundle+current.swift
//  FBusiness
//
//

import UIKit

extension Bundle {
    
    static var currentBase: Bundle {
        get {
            return Bundle(for: BaseViewController.self)
        }
    }
    
}
