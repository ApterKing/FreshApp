//
//  HomeNavigationBarView.swift
//  AGGeometryKit
//
//

import UIKit
import SwiftX

class HomeNavigationBarView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var buttonMessage: UIButton!
    @IBOutlet weak var buttonSearch: UIButton!
    class func loadFromXib() -> HomeNavigationBarView {
        
        if let view = Bundle.currentHome.loadNibNamed("HomeNavigationBarView", owner: self, options: nil)?.first as? HomeNavigationBarView {
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.navigationBarHeight)
            return view
        }
        return HomeNavigationBarView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonMessage.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        buttonSearch.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        if sender.tag == 0 {
            MessageViewController.show()
        } else if sender.tag == 1 {
            SearchViewController.show()
        } else {
            let vc = CitySelectedViewController()
            vc.hidesBottomBarWhenPushed = true
            topNavigationController?.pushViewController(vc, animated: true)
        }
    }
}
