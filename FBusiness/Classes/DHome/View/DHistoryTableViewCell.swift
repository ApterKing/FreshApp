//
//  DHistoryTableViewCell.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/26.
//

import UIKit

class DHistoryTableViewCell: UITableViewCell {
    
    static let height: CGFloat = 155

    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var SNoLabel: UILabel!
    
    var model: OrderDetailModel? {
        didSet {
            guard let model = self.model, let order = model.order, let addressInfo = model.addressInfo else { return }
            
            if let downTime = order.doneTime {
                timeLabel.text = Date(timeIntervalSince1970: downTime / 1000).format(to: "yyyy年MM月dd日 HH:mm")
            } else {
                timeLabel.text = Date(timeIntervalSince1970: order.orderTime / 1000).format(to: "yyyy年MM月dd日 HH:mm")
            }

            toLabel.text = "\(addressInfo.area ?? "")\(addressInfo.userAddress ?? "")"
            
            nameLabel.text = addressInfo.userName
            SNoLabel.text = order.orderSNo
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cornerView.round(byRoundingCorners: UIRectCorner(rawValue: UIRectCorner.topRight.rawValue | UIRectCorner.bottomRight.rawValue), cornerRadi: 5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
