//
//  MineTableViewCell.swift
//  FBusiness
//
//

import UIKit

class MineTableViewCell: BaseTableViewCell {
    
    static let height: CGFloat = 45
    
    @IBOutlet weak var iconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var indicatorView: UIImageView!

    @IBOutlet weak var indicatorTralingConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        subLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
