//
//  OrderProductTableViewCell.swift
//  FBusiness
//
//

import UIKit

class OrderProductTableViewCell: BaseTableViewCell {

    static public let height: CGFloat = 95
    
    @IBOutlet weak var imgv: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var specialView: UIView!
    @IBOutlet weak var specialTagView: UIView!
    @IBOutlet weak var specialTagLabel: UILabel!
    @IBOutlet weak var specialPriceLabel: UILabel!
    @IBOutlet weak var specialPromptLabel: UILabel!
    
    @IBOutlet weak var priceCountLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceDiscountLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    var model: ProductModel? {
        didSet {
            guard let model = self.model else { return }

            imgv.kf_setImage(urlString: model.productThumbUrl, placeholder: Constants.defaultPlaceHolder)
            nameLabel.text = model.productName
            
            let count = model.count ?? 0
            let productType =  ProductModel.ProductType(rawValue: model.productType ?? "") ?? .normal
            var priceDiscountText = ""
            if productType != ProductModel.ProductType.normal {  // 特价和专属商品
                specialView.isHidden = false
                
                specialTagLabel.text = productType.description
                specialPriceLabel.text = nil
                specialPromptLabel.isHidden = true
                
                if productType == ProductModel.ProductType.specialPrice {  // 是特价
                    priceCountLabel.text = "\((model.productSpecialPrice ?? 0)) x \(count)\(model.formatProductUnit)"
                    specialPriceLabel.text = String(format: "￥%.2f", (model.productSpecialPrice ?? 0) * Float(model.count ?? 0))
                    priceDiscountText = String(format: "￥%.2f", (model.productSpecialPrice ?? 0) * Float(model.count ?? 0))
                } else {    // 专属优惠
                    priceCountLabel.text = "\((model.productDiscountPrice ?? 0)) x \(count)\(model.formatProductUnit)"
                    priceDiscountText = String(format: "￥%.2f", (model.productDiscountPrice ?? 0) * Float(model.count ?? 0))
                }
            } else {   // 普通商品
                specialView.isHidden = true
                priceCountLabel.text = "\((model.productDiscountPrice ?? 0)) x \(count)\(model.formatProductUnit)"
                priceDiscountText = String(format: "￥%.2f", (model.productDiscountPrice ?? 0) * Float(model.count ?? 0))
            }
            
            let priceText = String(format: "￥%.2f", (model.productPrice ?? 0) * Float(model.count ?? 0))
            let attributedString = NSMutableAttributedString(string: priceText, attributes: [NSAttributedString.Key.strikethroughStyle: 1])
            priceLabel.attributedText = attributedString
            priceDiscountLabel.text = priceDiscountText
            
            priceLabel.isHidden = priceText == priceDiscountText
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        specialTagView.addGestureRecognizer(gesture)
        _ = gesture.rx.event
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { (_) in
                CategoryPrivilegeViewController.show()
            })
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let convertPoint = self.convert(point, to: specialTagView)
        if specialTagView.frame.contains(convertPoint) {
            return specialTagView
        }
        return super.hitTest(point, with: event)
    }
    
}
