//
//  LoginThirdPartyView.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class LoginThirdPartyView: UIView {
    static let height: CGFloat = UIDevice.iphone_667_or_less ? 180 : 200
    
    typealias ClickHandler = ((_ type: LoginThirdType) -> Void)
    enum LoginThirdType: Int {
        case qq = 0
        case wechat = 1
        case weibo = 2
    }
    var handler: ClickHandler?

    class func loadFromXib() -> LoginThirdPartyView {
        
        if let view = Bundle.currentLogin.loadNibNamed("LoginThirdPartyView", owner: self, options: nil)?.first as? LoginThirdPartyView {
            view.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.size.width, height: LoginThirdPartyView.height)
            return view
        }
        return LoginThirdPartyView()
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        handler?(LoginThirdType(rawValue: sender.tag) ?? .qq)
    }
}
