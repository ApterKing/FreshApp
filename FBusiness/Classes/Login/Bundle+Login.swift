//
//  Bundle+current.swift
//  FBusiness
//
//

import UIKit

extension Bundle {
    
    static var currentLogin: Bundle {
        get {
            return Bundle(for: LoginViewController.self)
        }
    }
    
}
