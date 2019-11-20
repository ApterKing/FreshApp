//
//  PrivilegeTableViewCell.swift
//  FBusiness
//
//

import UIKit

class PrivilegeTableViewCell: BaseTableViewCell {
    
    static let height: CGFloat = 40

    @IBOutlet weak var text0Label: UILabel!
    @IBOutlet weak var text1Label: UILabel!
    
    var model: CategoryModel? {
        didSet {
            if let model = model {

                if let config = model.config {
                    text0Label.text = model.catelogName
                    text1Label.text = String(format: "享%.1f折优惠", (config.discount ?? 0.9) * 10)
                }
                
                if let discount = model.discount {
                    text0Label.text = discount.catelogName
                    text1Label.text = String(format: "享%.1f折优惠", (discount.discount ?? 0.9) * 10)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
