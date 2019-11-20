//
//  OrderProductTableViewCell.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/14.
//

import UIKit

class DHomeDetailTableViewCell: BaseTableViewCell {

    static public let height: CGFloat = 95
    
    @IBOutlet weak var imgv: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceCountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceDiscountLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    public var model: ProductModel? {
        didSet {
            if let model = model {
                imgv.kf_setImage(urlString: model.productThumbUrl, placeholder: Constants.defaultPlaceHolder)
                nameLabel.text = model.productName
                priceCountLabel.text = String(format: "￥%.2f x %d", model.productDiscountPrice ?? 0, model.count ?? 0)
                
                let priceText = String(format: "￥%.2f", (model.productPrice ?? 0) * Float(model.count ?? 0))
                let attributedString = NSMutableAttributedString(string: priceText, attributes: [NSAttributedString.Key.strikethroughStyle: 1])
                priceLabel.attributedText = attributedString
                priceDiscountLabel.text = String(format: "￥%.2f", (model.productDiscountPrice ?? 0) * Float(model.count ?? 0))
            }
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
