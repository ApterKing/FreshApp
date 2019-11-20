//
//  OrderSuccessViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX

public class OrderSuccessViewController: BaseViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension OrderSuccessViewController {

    public func show(_ complection: (() -> Void)? = nil) {
        let vc = OrderSuccessViewController(nibName: "OrderSuccessViewController", bundle: Bundle.currentCommon)
        let navc = XBaseNavigationController(rootViewController: vc)
        topNavigationController?.present(navc, animated: true, completion: {
            complection?()
        })
    }
    
}
