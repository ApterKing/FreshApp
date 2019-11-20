//
//  CategoryPrivilegeViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class CategoryPrivilegeViewController: BaseViewController {
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height - UIScreen.navigationBarHeight - UIScreen.homeIndicatorMoreHeight))
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.backgroundColor = UIColor.white
        return sv
    }()
    
    private lazy var privilegeView = CategoryPrivilegeView.loadFromXib()

    override func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
}

extension CategoryPrivilegeViewController {
    
    private func _initUI() {
        navigationItem.title = "折扣规则"
        view.addSubview(scrollView)
        scrollView.addSubview(privilegeView)
        privilegeView.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: privilegeView.contentHeight)
        scrollView.contentSize = CGSize(width: UIScreen.width, height: privilegeView.contentHeight)
    }
    
}

extension CategoryPrivilegeViewController {
    
    static public func show() {
        let vc = CategoryPrivilegeViewController()
        vc.hidesBottomBarWhenPushed = true
        topNavigationController?.pushViewController(vc, animated: true)
    }
    
}
