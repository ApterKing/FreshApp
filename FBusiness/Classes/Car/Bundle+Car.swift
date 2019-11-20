//
//  Bundle+current.swift
//  FBusiness
//
//

import UIKit

extension Bundle {
    
    static var currentCar: Bundle {
        get {
            return Bundle(for: CarViewController.self)
        }
    }
    
}
