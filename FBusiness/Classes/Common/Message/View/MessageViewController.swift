//
//  MessageViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX

public class MessageViewController: BaseViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
    }
    
}

extension MessageViewController {
    
    private func _initUI() {
        navigationItem.title = "通知消息"

    }
    
}

extension MessageViewController {
    
    static public func show() {
        UserVModel.default.verify({ (success) in
            let vc = MessageViewController()
            vc.hidesBottomBarWhenPushed = true
            topNavigationController?.pushViewController(vc, animated: true)
        })
    }
    
}
