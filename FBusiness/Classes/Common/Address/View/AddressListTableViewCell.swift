//
//  AddressListTableViewCell.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class AddressListTableViewCell: BaseTableViewCell {
    
    static let height: CGFloat = 105

    @IBOutlet weak var namePhoneLabel: UILabel!
    @IBOutlet weak var defaultLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var model: AddressModel? {
        didSet {
            namePhoneLabel.text = "\(model?.userName ?? "")   \(model?.userPhone ?? "")"
            defaultLabel.isHidden = model?.isDefault == "no"
            addressLabel.text =  "\(model?.area ?? "")\(model?.userAddress ?? "")"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        defaultLabel.layer.borderColor = UIColor(hexColor: "#ED9E32").cgColor
        addressLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
