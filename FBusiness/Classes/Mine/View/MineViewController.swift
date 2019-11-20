//
//  MineViewController.swift
//  FBusiness
//
//

import UIKit

public class MineViewController: BaseViewController {

    private let headerView = MineTableViewHeaderView.loadFromXib()
    private lazy var tableView: UITableView = {
        let tv = UITableView.default
        tv.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height - UIScreen.tabBarHeight)
        tv.tableHeaderView = headerView
        tv.register(UINib(nibName: "MineTableViewCell", bundle: Bundle.currentMine), forCellReuseIdentifier: NSStringFromClass(MineTableViewCell.self))
        tv.register(UINib(nibName: "MineEmptyTableViewCell", bundle: Bundle.currentMine), forCellReuseIdentifier: NSStringFromClass(MineEmptyTableViewCell.self))
        tv.showsVerticalScrollIndicator = false
        tv.bounces = false
        tv.dataSource = self
        tv.delegate = self
        tv.backgroundColor = UIColor(hexColor: "#f7f7f7")
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 40))
        footerView.backgroundColor = UIColor.clear
        tv.tableFooterView = footerView
        return tv
    }()
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UserVModel.default.userInfoRefresh { [weak self] (_, error) in
            if error == nil {
                self?.headerView.resetInfo()
            }
        }
    }

}

extension MineViewController {
    
    private func _initUI() {
        isNavigationBarHiddenIfNeeded = true
        view.addSubview(tableView)
        
        headerView.resetInfo()
    }
    
}

extension MineViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0, let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MineTableViewCell.self)) as? MineTableViewCell {
            if indexPath.row == 0 {
                cell.icon.image = UIImage(named: "icon_mine_home_keeping", in: Bundle.currentMine, compatibleWith: nil)
                cell.label.text = "家政服务"
            } else if indexPath.row == 2 {
                cell.icon.image = UIImage(named: "icon_mine_income", in: Bundle.currentMine, compatibleWith: nil)
                cell.label.text = "我的收入"
            } else if indexPath.row == 4 {
                cell.icon.image = UIImage(named: "icon_mine_invitecode", in: Bundle.currentMine, compatibleWith: nil)
                cell.label.text = "填写邀请码"
            } else if indexPath.row == 6 {
                cell.icon.image = UIImage(named: "icon_mine_coupon", in: Bundle.currentMine, compatibleWith: nil)
                cell.label.text = "优惠券"
            } else if indexPath.row == 8 {
                cell.icon.image = UIImage(named: "icon_mine_location", in: Bundle.currentMine, compatibleWith: nil)
                cell.label.text = "地址管理"
            } else {
                cell.icon.image = UIImage(named: "icon_mine_setting", in: Bundle.currentMine, compatibleWith: nil)
                cell.label.text = "设置"
            }
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MineEmptyTableViewCell.self)) as? MineEmptyTableViewCell {
            cell.isUserInteractionEnabled = false
            return cell
        }
        return UITableViewCell()
    }

}

extension MineViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return MineTableViewCell.height
        }
        return MineEmptyTableViewCell.height
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            HouseKeepingContainer.show()
        case 2:
            FlowCashViewController.show()
        case 4:
            InputCodeViewController.show()
        case 6:
            CouponViewController.show()
        case 8:
            AddressListViewController.show()
        default:
            SettingViewController.show()
        }
    }
    
}
