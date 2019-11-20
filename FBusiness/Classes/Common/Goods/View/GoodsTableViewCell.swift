//
//  GoodsTableViewCell.swift
//  FBusiness
//
//

import UIKit
import Kingfisher

public class GoodsTableViewCell: BaseTableViewCell {
    
    static let height: CGFloat = 115

    @IBOutlet weak var imgv: UIImageView!
    @IBOutlet weak var stockLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceDiscountLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var sellView: UIView!
    @IBOutlet weak var sellHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var sellProgressView: UIView!
    private var sellProgressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor(hexColor: "#66B30C").cgColor
        layer.lineCap = CAShapeLayerLineCap.round
        layer.lineWidth = 6
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeEnd = 0.5
        return layer
    }()
    
    @IBOutlet weak var suspendSaleView: UIView!
    @IBOutlet weak var suspendSaleLabel: UILabel!
    var sellProgressShouldHidden: Bool = false {
        didSet {
            sellHeightConstraint.constant = sellProgressShouldHidden ? 0 : 12
            sellView.isHidden = sellProgressShouldHidden
        }
    }
    var model: ProductModel? {
        didSet {
            guard let model = self.model else { return }
            imgv.kf_setImage(urlString: model.productThumbUrl, placeholder: Constants.defaultPlaceHolder)
            nameLabel.text = model.productName
            descLabel.text = model.productDescription
            let attributedString = NSMutableAttributedString(string: String(format: "￥%.2f", model.productPrice ?? 0), attributes: [NSAttributedString.Key.strikethroughStyle: 1])
            priceLabel.attributedText = attributedString
            priceDiscountLabel.text =  "\(String(format: "￥%.2f", model.productDiscountPrice ?? 0))\(model.formatProductUnit)"
            priceLabel.isHidden = (model.productPrice ?? 0) == (model.productDiscountPrice ?? 0)
            
            if model.productStatus ?? .normal != .normal || model.stock ?? 0 == 0 {
                stockLabel.isHidden = false
                addButton.isHidden = true
            } else {
                stockLabel.isHidden = true
                addButton.isHidden = false
            }

            // 判定是否显示暂停销售
            suspendSaleView.isHidden = true
            suspendSaleLabel.text = "水果每日 18:00-\(CityVModel.default.currentCity?.config?.orderDeadline ?? "21:00") 暂停销售"
            if CategoryVModel.default.shouldShowSuspendSalePrompt(levelOne: model.pCatelogId) {
                suspendSaleView.isHidden = false
                stockLabel.isHidden = true
                addButton.isHidden = true
            }
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        priceLabel.text = ""
        sellProgressView.layer.cornerRadius = 4
        sellProgressView.layer.borderColor = UIColor(hexColor: "#66B30C").cgColor
        sellProgressView.layer.borderWidth = 0.5
        sellProgressView.layer.addSublayer(sellProgressLayer)
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        sellProgressLayer.path = UIBezierPath(rect: sellProgressView.bounds).cgPath
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        UserVModel.default.verify { (success) in
            if success {
                guard let model = self.model else { return }
                CarVModel.default.checkStock(product: model, complection: { (success) in
                    if success {
                        CarVModel.default.add(model.productId, 1)
                    }
                })
            }
        }
    }
    
}
