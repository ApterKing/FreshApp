//
//  OrderSubmitTableViewCell.swift
//  FBusiness
//
//

import UIKit

public class OrderSubmitTableViewCell: BaseTableViewCell {
    
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
    
    public var shouldPriceHidden: Bool = false {
        didSet {
            priceLabel.isHidden = shouldPriceHidden
        }
    }
    
    @IBOutlet weak var separatorView: UIView!
    private var model: CarModel?
    
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
    
}

extension OrderSubmitTableViewCell {
    
    // 数据 及 是否已经显示过特价
    func setData(_ model: CarModel, _ hasSpecial: Bool = false) {
        self.model = model
        
        imgv.kf_setImage(urlString: model.productThumbUrl, placeholder: Constants.defaultPlaceHolder)
        nameLabel.text = model.productName
        
        // 优惠列表数据 （取一级分类）
        let categories = CategoryVModel.default.datas.filter { (model) -> Bool in
            return model.config != nil
        }
        let categoryIds = categories.map { (model) -> String in
            return model.catelogId
        }
        
        // 我的专属优惠列表（一级分类）
        let discounts = UserVModel.default.currentUser?.config?.discounts ?? []
        let discountIds = discounts.map { (discount) -> String in
            return discount.catelogId
        }
        
        let pCategoryId = model.pCatelogId ?? ""
        let productType =  ProductModel.ProductType(rawValue: model.productType ?? "") ?? .normal
        var priceDiscountText = ""
        if productType != ProductModel.ProductType.normal {  // 特价和专属商品
            specialView.isHidden = false
            specialTagLabel.text = productType.description
            
            // 如果未有特价
            if !hasSpecial && productType == ProductModel.ProductType.specialPrice {  // 没有特价，并且是特价
                specialPriceLabel.text = String(format: "￥%.2f", model.productSpecialPrice ?? 0)
                specialPromptLabel.text = "x 1\(model.formatProductUnit)"
                specialPromptLabel.isHidden = false
                priceCountLabel.text = String(format: "￥%.2f x %d\(model.formatProductUnit)", model.productDiscountPrice ?? 0, max(model.count - 1, 0))
                priceDiscountText = String(format: "￥%.2f", (model.productSpecialPrice ?? 0) + (model.productDiscountPrice ?? 0) * Float(max(model.count - 1, 0)))
                if model.count == 1 {
                    priceCountLabel.text = nil
                } else {
                    if discountIds.contains(pCategoryId) {  // 计算专属折扣
                        for discount in discounts {
                            if discount.catelogId == model.pCatelogId {
                                priceCountLabel.text = String(format: "￥%.2f x %.2f x %d\(model.formatProductUnit)", model.productDiscountPrice ?? 0, discount.discount ?? 0.9, max(model.count - 1, 0))
                                priceDiscountText = String(format: "￥%.2f", (model.productSpecialPrice ?? 0) + (model.productDiscountPrice ?? 0) * (discount.discount ?? 0.9) * Float(max(model.count - 1, 0)))
                                break
                            }
                        }
                    } else if categoryIds.contains(pCategoryId) {  // 计算分类折扣
                        for category in categories {
                            if category.catelogId == pCategoryId {
                                priceCountLabel.text = String(format: "￥%.2f x %.2f x %d\(model.formatProductUnit)", model.productDiscountPrice ?? 0, category.config?.discount ?? 0.9, max(model.count - 1, 0))
                                
                                var priceDiscount = (model.productSpecialPrice ?? 0)
                                priceDiscount += ((model.productDiscountPrice ?? 0) * (category.config?.discount ?? 0.9) * Float(max(model.count - 1, 0)))
                                priceDiscountText = String(format: "￥%.2f",  priceDiscount)
                                break
                            }
                        }
                    }
                }
            } else if productType == ProductModel.ProductType.specialPrice {  // 是特价，但是在列表前面已经计算过特价了
                specialView.isHidden = true
                specialPriceLabel.text = String(format: "￥%.2f\(model.formatProductUnit)", model.productSpecialPrice ?? 0)
                specialPromptLabel.isHidden = true
                priceCountLabel.text = String(format: "￥%.2f x %d\(model.formatProductUnit)", model.productDiscountPrice ?? 0, max(model.count, 0))
                priceDiscountText = String(format: "￥%.2f", (model.productDiscountPrice ?? 0) * Float(max(model.count, 0)))
                
                let discounts = UserVModel.default.currentUser?.config?.discounts ?? []
                
                if discountIds.contains(pCategoryId) {  // 计算专属折扣
                    specialView.isHidden = false
                    for discount in discounts {
                        if discount.catelogId == model.pCatelogId {
                            specialPriceLabel.text = String(format: "专享%.1f折优惠", (discount.discount ?? 0.9) * 10)
                            
                            priceCountLabel.text = String(format: "￥%.2f x %.2f x %d\(model.formatProductUnit)", model.productDiscountPrice ?? 0, discount.discount ?? 0.9, model.count)
                            priceDiscountText = String(format: "￥%.2f", (model.productSpecialPrice ?? 0) + (model.productDiscountPrice ?? 0) * (discount.discount ?? 0.9) * Float(model.count))
                            break
                        }
                    }
                } else if categoryIds.contains(pCategoryId) {  // 计算分类折扣
                    specialView.isHidden = false
                    for category in categories {
                        if category.catelogId == pCategoryId {
                            specialPriceLabel.text = String(format: "享%.1f折优惠", (category.config?.discount ?? 0.9) * 10)
                            
                            priceCountLabel.text = String(format: "￥%.2f x %.2f x %d\(model.formatProductUnit)", model.productDiscountPrice ?? 0, category.config?.discount ?? 0.9, model.count)
                            let priceDiscount = ((model.productDiscountPrice ?? 0) * (category.config?.discount ?? 0.9) * Float(model.count))
                            priceDiscountText = String(format: "￥%.2f",  priceDiscount)
                            break
                        }
                    }
                }
            } else {    // 专属优惠
                specialView.isHidden = false
                specialPriceLabel.text = String(format: "专享9.0折优惠")
                specialPromptLabel.isHidden = true
                priceCountLabel.text = String(format: "￥%.2f x %.2f x %d\(model.formatProductUnit)", model.productDiscountPrice ?? 0, 0.9, model.count)
                priceDiscountText = String(format: "￥%.2f", (model.productDiscountPrice ?? 0) * 0.9 * Float(model.count))
                for discount in discounts {
                    if discount.catelogId == model.pCatelogId {
                        specialPriceLabel.text = String(format: "专享%.1f折优惠", (discount.discount ?? 0.9) * 10)
                        priceCountLabel.text = String(format: "￥%.2f x %.2f x %d\(model.formatProductUnit)", model.productDiscountPrice ?? 0, discount.discount ?? 0.9, model.count)
                        priceDiscountText = String(format: "￥%.2f", (model.productDiscountPrice ?? 0) * (discount.discount ?? 0.9) * Float(model.count))
                        break
                    }
                }
            }
        } else {   // 普通商品
            if categoryIds.contains(pCategoryId) {  // 计算分类折扣
                specialView.isHidden = false
                specialPriceLabel.text = String(format: "享9.0折优惠")
                specialPromptLabel.isHidden = true
                specialTagLabel.text = ProductModel.ProductType.category.description
                for category in categories {
                    if category.catelogId == pCategoryId {
                        specialPriceLabel.text = String(format: "享%.1f折优惠", (category.config?.discount ?? 0.9) * 10)
                        priceCountLabel.text = String(format: "￥%.2f x %.2f x %d\(model.formatProductUnit)", model.productDiscountPrice ?? 0, category.config?.discount ?? 0.9, model.count)
                        priceDiscountText = String(format: "￥%.2f", (model.productDiscountPrice ?? 0) * (category.config?.discount ?? 0.9) * Float(model.count))
                        break
                    }
                }
            } else {
                specialView.isHidden = true
                priceCountLabel.text = String(format: "￥%.2f x %d\(model.formatProductUnit)", model.productDiscountPrice ?? 0, model.count)
                priceDiscountText = String(format: "￥%.2f", (model.productDiscountPrice ?? 0) * Float(model.count))
            }
        }
        
        let priceText = String(format: "￥%.2f", (model.productPrice ?? 0) * Float(model.count))
        let attributedString = NSMutableAttributedString(string: priceText, attributes: [NSAttributedString.Key.strikethroughStyle: 1])
        priceLabel.attributedText = attributedString
        priceDiscountLabel.text = priceDiscountText
        priceLabel.isHidden = priceText == priceDiscountText
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let convertPoint = self.convert(point, to: specialTagView)
        if specialTagView.frame.contains(convertPoint) {
            return specialTagView
        }
        return super.hitTest(point, with: event)
    }
}
