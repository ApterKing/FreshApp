//
//  RewardIntroViewController.swift
//  AGGeometryKit
//
//

import UIKit
import SwiftX

class RewardIntroViewController: BaseViewController {
    
    @IBOutlet weak var text0Label: UILabel!
    @IBOutlet weak var text1Label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
    }

}

extension RewardIntroViewController {
    
    private func _initUI() {
        navigationItem.title = "奖励说明"
        text0Label.text = "您邀请的每一个用户，未来\(CommissionVModel.default.currentCommission?.i1CommissionValidDays ?? 365)天之内，在平台下单，您都能获得他下单金额的\(String(format: "%.1f", (CommissionVModel.default.currentCommission?.i1Commission ?? 2) * 100))%的收入提成。"
        text1Label.text = "被您邀请的每一个用户，如果邀请了新用户，这个新用户未来\(CommissionVModel.default.currentCommission?.i2CommissionValidDays ?? 365)天之内，在平台下单，您都能获得他下单金额的\(String(format: "%.1f", (CommissionVModel.default.currentCommission?.i2Commission ?? 1) * 100))%的收入提成。"
    }
}

extension RewardIntroViewController {
    
    static public func show() {
        let vc = RewardIntroViewController(nibName: "RewardIntroViewController", bundle: Bundle.currentMine)
        vc.hidesBottomBarWhenPushed = true
        topNavigationController?.pushViewController(vc, animated: true)
    }
    
}

