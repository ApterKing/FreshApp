//
//  FlowCashTableViewCell.swift
//  FBusiness
//
//

import UIKit

class FlowCashTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var fromNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var reasonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var reasonView: UIView!
    @IBOutlet weak var reasonLabel: UILabel!
    
    var model: FlowCashModel? {
        didSet {
            guard let model = self.model else { return }
            let type = (FlowCashModel.FlowType(rawValue: model.flowType) ?? .reg)
            let status = FlowCashModel.Status(rawValue: model.flowStatus) ?? .unpaid

            timeLabel.text = Date(timeIntervalSince1970: model.flowTime / 1000).format(to: "MM-dd")
            
            cashLabel.text = String(format: "￥%.2f", model.flowMoney)
            reasonHeightConstraint.constant = 0
            reasonView.isHidden = true
            if type == .withdraw {
                switch status {
                case .unpaid:
                    typeLabel.text = "申请待转款"
                case .paid:
                    typeLabel.text = "提现成功"
                case .canceled:
                    typeLabel.text = "申请被驳回"
                    cashLabel.text = cashLabel.text?.replacingOccurrences(of: "-", with: "+")
                    reasonLabel.text = model.flowExtends == nil || model.flowExtends == "" ? "--" : model.flowExtends ?? ""
                    reasonHeightConstraint.constant = 44
                    reasonView.isHidden = false
                }
            } else {
                typeLabel.text = type.description
            }
            fromNameLabel.text = model.flowName
            fromLabel.text = model.fromUserName ?? "--"
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

extension FlowCashTableViewCell {

    static func calculate(with model: FlowCashModel) -> CGFloat {
        let type = (FlowCashModel.FlowType(rawValue: model.flowType) ?? .reg)
        let status = FlowCashModel.Status(rawValue: model.flowStatus) ?? .unpaid
        if type == .withdraw && status == .canceled {
            return 44 * 5 + 20
        } else {
            return 44 * 4 + 20
        }
    }

}
