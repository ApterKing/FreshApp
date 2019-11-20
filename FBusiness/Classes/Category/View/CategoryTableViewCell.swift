//
//  CategoryTableViewCell.swift
//  FBusiness
//
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    static let height: CGFloat = 60

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var couponImageView: UIImageView!
    
    var model: CategoryModel? {
        didSet {
            if let model = model {
                nameLabel.text = model.catelogName
                let categoryIds = UserVModel.default.currentUser?.config?.discounts?.map({ (discount) -> String in
                    return discount.catelogId
                }) ?? []
                couponImageView.isHidden = model.config == nil && !categoryIds.contains(model.catelogId)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let selBackgroundView = UIView()
        selBackgroundView.backgroundColor = UIColor.white
        self.selectedBackgroundView = selBackgroundView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
