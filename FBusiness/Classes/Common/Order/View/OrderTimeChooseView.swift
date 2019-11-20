//
//  OrderTimeChooseView.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster

class OrderTimeChooseView: UIView {
    typealias ComplectionHandler = ((_ dayFormat: String, _ model: DeliveryTimeModel) -> Void)
    
    private let contentViewHeight: CGFloat = (UIScreen.width * 3 / 4)

    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var heightContentConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContentConstraint: NSLayoutConstraint!
    @IBOutlet weak var lTableView: UITableView!
    @IBOutlet weak var rTableView: UITableView!
    
    @IBOutlet weak var bottomCertainConstraint: NSLayoutConstraint!
    private let vmodel = OrderTimeVModel()
    private var keys: [String] = []
    private var lSelectedIndexPath: IndexPath?
    private var rSelectedIndexPath: IndexPath?
    
    var handler: ComplectionHandler?
    
    class func loadFromXib() -> OrderTimeChooseView {
        if let view = Bundle.currentCommon.loadNibNamed("OrderTimeChooseView", owner: self, options: nil)?.first as? OrderTimeChooseView {
            view.frame = UIScreen.main.bounds
            return view
        }
        return OrderTimeChooseView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        opacityView.alpha = 0.01
        heightContentConstraint.constant = contentViewHeight
        bottomCertainConstraint.constant = UIScreen.homeIndicatorMoreHeight

        lTableView.dataSource = self
        lTableView.delegate = self
        lTableView.register(LeftTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(LeftTableViewCell.self))
        
        rTableView.dataSource = self
        rTableView.delegate = self
        rTableView.register(RightTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(RightTableViewCell.self))
    
        _loadData()
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        _dismiss()
        if sender.tag == 1 {
            _handleSelected()
        }
    }
}

extension OrderTimeChooseView {
    
    private func _loadData() {
        vmodel.fetch { [weak self] (error) in
            guard let weakSelf = self else { return }
            weakSelf.lTableView.reloadData()
            weakSelf.rTableView.reloadData()
            
            let tomorroeEnable = weakSelf.vmodel.tomorrowTimes.filter({ (model) -> Bool in
                return model.enable == "yes"
            }).count != 0
            weakSelf.lSelectedIndexPath = IndexPath(row: tomorroeEnable ? 0 : 1, section: 0)
            self?.lTableView.selectRow(at: IndexPath(row: tomorroeEnable ? 0 : 1, section: 0), animated: true, scrollPosition: .none)
            let times = tomorroeEnable ? weakSelf.vmodel.tomorrowTimes : weakSelf.vmodel.afterTomorrowTimes
            for (index, model) in times.enumerated() {
                if model.enable == "yes" {
                    weakSelf.rSelectedIndexPath = IndexPath(row: index, section: 0)
                    weakSelf.rTableView.selectRow(at: weakSelf.rSelectedIndexPath!, animated: true, scrollPosition: .none)
                    break
                }
            }
            weakSelf._handleSelected()
        }
    }
    
    private func _handleSelected() {
        let lSelectedIndex = lSelectedIndexPath?.row ?? 0
        if lSelectedIndex == 0 { // 明天
            if let rSelectedIndex = rSelectedIndexPath?.row, rSelectedIndex < vmodel.tomorrowTimes.count {
                print("_handleSelected   明天   \(rSelectedIndex)")
                handler?(Date().adding(.day, value: lSelectedIndex + 1).format(to: "yyyy-MM-dd"), vmodel.tomorrowTimes[rSelectedIndex])
            }
        } else {  // 后天
            if let rSelectedIndex = rSelectedIndexPath?.row, rSelectedIndex < vmodel.afterTomorrowTimes.count {
                print("_handleSelected   后天  \(rSelectedIndex)")
                handler?(Date().adding(.day, value: lSelectedIndex + 1).format(to: "yyyy-MM-dd"), vmodel.afterTomorrowTimes[rSelectedIndex])
            }
        }
    }
    
    private func _show() {
        self.frame = topViewController?.view.bounds ?? UIScreen.main.bounds
        topViewController?.view.addSubview(self)
        opacityView.alpha = 0.01
        bottomContentConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.opacityView.alpha = 0.7
            self.layoutIfNeeded()
        }
    }
    
    private func _dismiss(_ agreed: Bool = false) {
        bottomContentConstraint.constant = -contentViewHeight
        UIView.animate(withDuration: 0.25, animations: {
            self.opacityView.alpha = 0.01
            self.layoutIfNeeded()
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
}

extension OrderTimeChooseView {
    
    func show() {
        _show()
    }

    func dismiss() {
        _dismiss()
    }
}

extension OrderTimeChooseView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == lTableView {
            return 2
        } else {
            let lSelectedIndex = lSelectedIndexPath?.row ?? 0
            return lSelectedIndex == 0 ? vmodel.tomorrowTimes.count : vmodel.afterTomorrowTimes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == lTableView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LeftTableViewCell.self)) as? LeftTableViewCell {
                if indexPath.row == 0 {
                    cell.label.text = "明天"
                } else {
                    cell.label.text = Date().adding(.day, value: indexPath.row + 1).format(to: "MM-dd")
                }
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(RightTableViewCell.self)) as? RightTableViewCell {
                let lSelectedIndex = lSelectedIndexPath?.row ?? 0
                if lSelectedIndex == 0 {
                    cell.model = vmodel.tomorrowTimes[indexPath.row]
                    cell.separatorLine.isHidden = indexPath.row == vmodel.tomorrowTimes.count - 1
                } else {
                    cell.model = vmodel.afterTomorrowTimes[indexPath.row]
                    cell.separatorLine.isHidden = indexPath.row == vmodel.afterTomorrowTimes.count - 1
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
}

extension OrderTimeChooseView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == lTableView {
            lSelectedIndexPath = indexPath
            rSelectedIndexPath = nil
            rTableView.reloadData()
            
            let timeModels = indexPath.row == 0 ? vmodel.tomorrowTimes : vmodel.afterTomorrowTimes
            for (index, model) in timeModels.enumerated() {
                if model.enable == "yes" {
                    rSelectedIndexPath = IndexPath(row: index, section: 0)
                    rTableView.selectRow(at: rSelectedIndexPath!, animated: true, scrollPosition: .none)
                    break
                }
            }
        } else {
            let lSelectedIndex = lSelectedIndexPath?.row ?? 0
            if lSelectedIndex == 0 {
                guard vmodel.tomorrowTimes[indexPath.row].enable == "yes" else {
                    Toast.show("今天的订单量已经爆仓啦，请您明天提早预定哦~")
                    tableView.deselectRow(at: indexPath, animated: true)
                    return
                }
                rSelectedIndexPath = indexPath
            } else {
                guard vmodel.afterTomorrowTimes[indexPath.row].enable == "yes" else {
                    Toast.show("今天的订单量已经爆仓啦，请您明天提早预定哦~")
                    tableView.deselectRow(at: indexPath, animated: true)
                    return
                }
                rSelectedIndexPath = indexPath
            }
        }
    }
    
}

// 左侧cell
extension OrderTimeChooseView {
    
    class LeftTableViewCell: BaseTableViewCell {
        
        lazy var label: UILabel = {
            let label = UILabel()
            label.text = "今天"
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = UIColor(hexColor: "#333333")
            label.textAlignment = .center
            return label
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.backgroundColor = UIColor(hexColor: "#f7f7f7")
            contentView.addSubview(label)
            label.snp.makeConstraints {
                $0.left.equalTo(10)
                $0.right.equalTo(10)
                $0.centerY.equalTo(contentView.snp.centerY)
            }
            
            let selBackgroundView = UIView()
            selBackgroundView.backgroundColor = UIColor.white
            self.selectedBackgroundView = selBackgroundView
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
}

// 右侧
extension OrderTimeChooseView {
    
    class RightTableViewCell: BaseTableViewCell {
        
        lazy var text0Label: UILabel = {
            let label = UILabel()
            label.text = "11:00-12:00"
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = UIColor(hexColor: "#333333")
            label.highlightedTextColor = UIColor(hexColor: "#66B30C")
            return label
        }()
        lazy var text1Label: UILabel = {
            let label = UILabel()
            label.text = "差xxx免配送费"
            label.font = UIFont.systemFont(ofSize: 11)
            label.textAlignment = .left
            label.textColor = UIColor(hexColor: "#666666")
            label.highlightedTextColor = UIColor(hexColor: "#66B30C")
            label.adjustsFontSizeToFitWidth = true
            return label
        }()
        lazy var text2Label: UILabel = {
            let label = UILabel()
            label.text = "满xxxx免配送费"
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(hexColor: "#FFA301")
            label.highlightedTextColor = UIColor(hexColor: "#66B30C")
            label.adjustsFontSizeToFitWidth = true
            return label
        }()
        
        lazy var separatorLine: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(hexColor: "#f7f7f7")
            return view
        }()
        
        var model: DeliveryTimeModel? {
            didSet {
                if let model = model {
                    text0Label.text = "\(model.deliverStartTime)-\(model.deliverEndTime)"
                    let price = CarVModel.default.checkedPrice()
                    if (price >= model.deliverFreeOrderMoney ?? 0) {
                        text1Label.text = "免配送费"
                        text1Label.textColor = UIColor(hexColor: "#66B30C")
                    } else {
                        text1Label.text = String(format: "差￥%.2f元免配送费", (model.deliverFreeOrderMoney ?? 0) - price)
                        text1Label.textColor = UIColor(hexColor: "#666666")
                    }
                    text2Label.text = String(format: "商品金额满￥%.2f元免配送费", model.deliverFreeOrderMoney ?? 0)
                }
            }
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.backgroundColor = UIColor.clear
            contentView.addSubview(text0Label)
            text0Label.snp.makeConstraints {
                $0.left.equalTo(15)
                $0.centerY.equalTo(contentView.snp.centerY).offset(-10)
            }
            
            contentView.addSubview(text1Label)
            text1Label.snp.makeConstraints {
                $0.right.equalTo(-5)
                $0.left.equalTo(text0Label.snp.right).offset(5)
                $0.bottom.equalTo(text0Label.snp.bottom).offset(-2)
            }
            
            contentView.addSubview(text2Label)
            text2Label.snp.makeConstraints {
                $0.centerY.equalTo(contentView.snp.centerY).offset(14)
                $0.left.equalTo(text0Label)
                $0.right.equalTo(5)
            }
            
            contentView.addSubview(separatorLine)
            separatorLine.snp.makeConstraints {
                $0.left.equalTo(5)
                $0.bottom.equalTo(0)
                $0.right.equalTo(-5)
                $0.height.equalTo(1)
            }
            
            let selBackgroundView = UIView()
            selBackgroundView.backgroundColor = UIColor.white
            self.selectedBackgroundView = selBackgroundView
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

