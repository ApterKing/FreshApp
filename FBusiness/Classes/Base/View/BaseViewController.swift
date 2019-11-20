//
//  BaseViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import RxSwift

public class BaseViewController: XBaseViewController {

    let bag = DisposeBag()
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()

    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if FRESH_CLIENT
        FloatingCarView.default.changeVisiable()
        #endif
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
