//
//  ViewController.swift
//  Fresh
//
//

import UIKit
import FBusiness
import SwiftX

class ViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        _initUI()
    }

}

extension ViewController {
    
    func _initUI() {
        delegate = self
        
        let homeVC = XBaseNavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "首页", image: UIImage(named: "icon_tab_home"), selectedImage: UIImage(named: "icon_tab_home"))
        
        let categoryVC = XBaseNavigationController(rootViewController: CategoryViewController())
        categoryVC.tabBarItem = UITabBarItem(title: "分类", image: UIImage(named: "icon_tab_category"), selectedImage: UIImage(named: "icon_tab_category"))
        
        let carVC = XBaseNavigationController(rootViewController: CarViewController())
        carVC.tabBarItem = UITabBarItem(title: "购物车", image: UIImage(named: "icon_tab_car"), selectedImage: UIImage(named: "icon_tab_car"))
        
        let mineVC = XBaseNavigationController(rootViewController: MineViewController())
        mineVC.tabBarItem = UITabBarItem(title: "我的", image: UIImage(named: "icon_tab_mine"), selectedImage: UIImage(named: "icon_tab_mine"))
        
        setViewControllers([homeVC, categoryVC, carVC, mineVC], animated: true)
        
        tabBar.unselectedItemTintColor = UIColor(hexColor: "#D8D8D8")
        tabBar.tintColor = UIColor(hexColor: "#66B30C")
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexColor: "#D8D8D8")], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexColor: "#66B30C")], for: .selected)
    }
}

extension ViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        NotificationCenter.default.post(name: Constants.notification_tabbar_selectedIndex_changed, object: selectedIndex)
    }
    
}

