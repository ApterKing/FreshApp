//
//  OrderSubmitCouponCollectionViewCell.swift
//  FBusiness
//
//

import UIKit

class OrderSubmitCouponCollectionViewCell: UICollectionViewCell {
    
    static let size = CGSize(width: 210, height: 80)

    @IBOutlet weak var text0Label: UILabel!
    @IBOutlet weak var text1Label: UILabel!
    @IBOutlet weak var text2Label: UILabel!
    
    var model: CouponModel? {
        didSet {
            if let model = model {
                let type = CouponModel.CouponType(rawValue: model.couponType) ?? .discount
                if type == .discount {
                    text0Label.text = String(format: "%.1f折", (model.couponConfig?.discount ?? 0.9) * 10)
                } else {
                    text0Label.text = String(format: "%.1f", (model.couponConfig?.reduce ?? 0))
                }

                let desc = type.description
                let time = Date(timeIntervalSince1970: TimeInterval(model.couponExpiredTime/1000)).format(to: "MM-dd")
                let text = "\(desc)(\(time)过期)"
                let attributeString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor(hexColor: "#666666")])
                let range = NSRange(location: 0, length: desc.count)
                attributeString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor(hexColor: "#333333")], range: range)
                text1Label.attributedText = attributeString
                
                let minConsum = model.couponConfig?.minConsum ?? 0
                text2Label.text = "\(minConsum == 0 ? "任意金额可用" : "满\(minConsum)可用")"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
