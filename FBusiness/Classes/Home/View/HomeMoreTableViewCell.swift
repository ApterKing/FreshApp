//
//  HomeMoreTableViewCell.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class HomeMoreTableViewCell: UITableViewCell {
    
    static let height: CGFloat = 60

    @IBOutlet weak var moreButton: UIButton!
    
    // 跳转需要的参数
    var titleString: String = ""
    var recommendId: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        moreButton.layer.cornerRadius = 5
        moreButton.layer.borderWidth = 1
        moreButton.layer.borderColor = UIColor(hexColor: "#65B10C").cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        let vc = HomeMoreViewController()
        vc.titleString = titleString
        vc.recommendId = recommendId
        vc.hidesBottomBarWhenPushed = true
        topNavigationController?.pushViewController(vc, animated: true)
    }
    
}
