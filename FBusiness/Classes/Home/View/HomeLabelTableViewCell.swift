//
//  HomeLabelTableViewCell.swift
//  FBusiness
//
//

import UIKit

class HomeLabelTableViewCell: UITableViewCell {
    
    static let height: CGFloat = 60

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
