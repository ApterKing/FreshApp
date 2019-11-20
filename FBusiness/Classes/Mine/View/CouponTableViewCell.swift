//
//  CouponTableViewCell.swift
//  FBusiness
//
//

import UIKit

class CouponTableViewCell: UITableViewCell {
    
    static let height: CGFloat = (UIDevice.isIphone4_5() ? 250 : 270)

    @IBOutlet weak var imgv: UIImageView!
    @IBOutlet weak var text0Label: UILabel!
    @IBOutlet weak var text1Label: UILabel!
    
    var model: CouponModel? {
        didSet {
            if let model = model, let type = CouponModel.CouponType(rawValue: model.couponType) {
                imgv.image = UIImage(named: type == CouponModel.CouponType.discount ? "icon_coupon_discount" : "icon_coupon_deduction", in: Bundle.currentBase, compatibleWith: nil)

                let desc = (CouponModel.CouponType(rawValue: model.couponType) ?? .discount).description
                var text = ""
                let minConsum = model.couponConfig?.minConsum ?? 0
                if type == .deduction {
                    let minus = model.couponConfig?.reduce ?? 0
                    text = String(format: "\(desc)（满%.1f减%.1f)）", minConsum, minus)
                } else {
                    let discount = (model.couponConfig?.discount ?? 0.99) * 10
                    text = String(format: "\(desc)（满%.1f享%.1f折优惠）", minConsum, discount)
                }
                let attributeString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
                let range = NSRange(location: 0, length: desc.count)
                attributeString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor(hexColor: "#333333")], range: range)
                text0Label.attributedText = attributeString
                
                text1Label.text = Date(timeIntervalSince1970: TimeInterval(model.couponExpiredTime / 1000)).format(to: "yyyy年MM月dd日 HH:mm过期")
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
