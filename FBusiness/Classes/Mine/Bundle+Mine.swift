//
//  Bundle+current.swift
//  FBusiness
//
//

import UIKit

extension Bundle {
    
    static var currentMine: Bundle {
        get {
            return Bundle(for: MineViewController.self)
        }
    }
    
}
