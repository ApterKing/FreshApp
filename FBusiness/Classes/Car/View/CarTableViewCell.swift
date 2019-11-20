//
//  CarTableViewCell.swift
//  FBusiness
//
//

import UIKit

class CarTableViewCell: BaseTableViewCell {
    
    typealias EditHandler = ((_ add: Bool, _ model: CarModel) -> Void)
    
    static let height: CGFloat = 110

    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var imgv: UIImageView!
    @IBOutlet weak var stockLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var specialView: UIView!
    @IBOutlet weak var specialTagView: UIView!
    @IBOutlet weak var specialTagLabel: UILabel!
    @IBOutlet weak var specialPriceLabel: UILabel!
    @IBOutlet weak var specialPromptLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceDiscountLabel: UILabel!

    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var separatorLine: UIView!

    @IBOutlet weak var suspendSaleView: UIView!
    @IBOutlet weak var suspendSaleLabel: UILabel!
    
    var handler: EditHandler?
    var model: CarModel? {
        didSet {
            guard let model = self.model else { return }
            checkImageView.image = UIImage(named: (model.isChecked ?? false) ? "icon_checked" : "icon_uncheck", in: Bundle.currentBase, compatibleWith: nil)
            imgv.kf_setImage(urlString: model.productThumbUrl, placeholder: Constants.defaultPlaceHolder)
            nameLabel.text = model.productName
            descLabel.text = model.productDescription
            let attributedString = NSMutableAttributedString(string: String(format: "￥%.2f\(model.formatProductUnit)", model.productPrice ?? 0), attributes: [NSAttributedString.Key.strikethroughStyle: 1])
            priceLabel.attributedText = attributedString
            priceDiscountLabel.text = String(format: "￥%.2f", model.productDiscountPrice ?? 0)

            priceLabel.isHidden = (model.productPrice ?? 0) == (model.productDiscountPrice ?? 0)
            if priceLabel.isHidden {
                priceDiscountLabel.text = "\(priceDiscountLabel.text ?? "")\(model.formatProductUnit)"
            }

            countLabel.text = "\(model.count)"
            
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
            
            let productType =  ProductModel.ProductType(rawValue: model.productType ?? "") ?? .normal
            let pCatelogId = model.pCatelogId ?? ""
            if productType != ProductModel.ProductType.normal {
                specialView.isHidden = false
                specialTagLabel.text = productType.description
                
                if productType == ProductModel.ProductType.specialPrice {
                    specialPriceLabel.text = String(format: "￥%.2f", model.productSpecialPrice ?? 0)
                    specialPromptLabel.text = "仅计算一件特价"
                    specialPromptLabel.isHidden = false
                } else {
                    let discounts = UserVModel.default.currentUser?.config?.discounts ?? []
                    specialPriceLabel.text = String(format: "享9.0折优惠")
                    if discountIds.contains(pCatelogId) {
                        for discount in discounts {
                            if discount.catelogId == model.pCatelogId {
                                specialPriceLabel.text = String(format: "专享%.1f折优惠", (discount.discount ?? 0.9) * 10)
                                break
                            }
                        }
                    }
                    specialPromptLabel.isHidden = true
                }
            } else {
                if categoryIds.contains(pCatelogId) {  // 分类折扣
                    specialView.isHidden = false
                    for category in categories {
                        if category.catelogId == pCatelogId {
                            specialTagLabel.text = ProductModel.ProductType.category.description
                            specialPriceLabel.text = String(format: "享%.1f折优惠", (category.config?.discount ?? 0.9) * 10)
                            break
                        }
                    }
                    specialPromptLabel.isHidden = true
                } else {
                    specialView.isHidden = true
                }
            }
            
            let soltOut = model.productStatus ?? .normal != .normal || (model.stock ?? 0) == 0
            stockLabel.isHidden = !soltOut
            minusButton.isHidden = soltOut
            countLabel.isHidden = soltOut
            addButton.isHidden = soltOut

            // 判定是否显示暂停销售
            suspendSaleView.isHidden = true
            suspendSaleLabel.text = "水果每日 18:00-\(CityVModel.default.currentCity?.config?.orderDeadline ?? "21:00") 暂停销售"
            if CategoryVModel.default.shouldShowSuspendSalePrompt(levelOne: model.pCatelogId) {
                suspendSaleView.isHidden = false
                stockLabel.isHidden = true
                minusButton.isHidden = true
                countLabel.isHidden = true
                addButton.isHidden = true
            }
        }
    }
    
    
    override func awakeFromNib() {
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        guard let model = self.model else { return }
        handler?(sender.tag == 1, model)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let convertPoint = self.convert(point, to: specialTagView)
        if specialTagView.frame.contains(convertPoint) && !CategoryVModel.default.shouldShowSuspendSalePrompt(levelOne: model?.pCatelogId) {
            return specialTagView
        }
        return super.hitTest(point, with: event)
    }
}
