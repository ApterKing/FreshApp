//
//  Bundle+current.swift
//  FBusiness
//
//

import UIKit

extension Bundle {
    
    static var currentCategory: Bundle {
        get {
            return Bundle(for: CategoryViewController.self)
        }
    }
    
}
