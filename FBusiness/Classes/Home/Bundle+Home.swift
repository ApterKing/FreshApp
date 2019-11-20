//
//  Bundle+current.swift
//  FBusiness
//
//

import UIKit

extension Bundle {
    
    static var currentHome: Bundle {
        get {
            return Bundle(for: HomeViewController.self)
        }
    }
    
}
