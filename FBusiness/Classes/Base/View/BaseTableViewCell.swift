//
//  BaseTableViewCell.swift
//  FBusiness
//
//

import UIKit

public class BaseTableViewCell: UITableViewCell {

    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(hexColor: "#f7f7f7")
        self.selectedBackgroundView = selectedBackgroundView
        
//        separatorInset = UIEdgeInsets(top: 0, left: UIScreen.width, bottom: 0, right: 0)
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
