//
//  SettingViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster

class SettingViewController: BaseViewController {

    private var vmodel = LoginVModel()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView.default
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height - UIScreen.navigationBarHeight - UIScreen.homeIndicatorMoreHeight - 50 - MineTableViewCell.height * 4))
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Copyright@2019-2025\n\n遂宁市三鲜科技有限公司 版权所有"
        label.numberOfLines = 0
        label.textColor = UIColor(hexColor: "#666666")
        tableFooterView.addSubview(label)
        label.snp.makeConstraints({
            $0.left.right.equalTo(0)
            $0.bottom.equalTo(-25)
        })
        tv.tableFooterView = tableFooterView
        tv.register(UINib(nibName: "MineTableViewCell", bundle: Bundle.currentMine), forCellReuseIdentifier: NSStringFromClass(MineTableViewCell.self))
        tv.register(UINib(nibName: "MineEmptyTableViewCell", bundle: Bundle.currentMine), forCellReuseIdentifier: NSStringFromClass(MineEmptyTableViewCell.self))
        tv.backgroundColor = UIColor(hexColor: "#f7f7f7")
        tv.showsVerticalScrollIndicator = false
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = true
    }
}

extension SettingViewController {
    
    private func _initUI() {
        navigationItem.title = "设置"
        
        let button = UIButton(frame: CGRect.zero)
        button.setTitle("退出登录", for: .normal)
        Theme.decorate(button: button, cornerRadius: 0)
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.left.right.equalTo(0)
            $0.bottom.equalTo(-UIScreen.homeIndicatorMoreHeight)
            $0.height.equalTo(UserVModel.default.isLogined ? 50 : 0)
        }
        _ = button.rx.controlEvent(.touchUpInside).asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.startHUDAnimation()
                self?.vmodel.logout({
                    self?.stopHUDAnimation()
                    self?.navigationController?.popViewController(animated: true)
                    LoginViewController.show()
                })
            })

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.left.right.equalTo(0)
            $0.bottom.equalTo(button.snp.top)
        }
    }
    
}

extension SettingViewController {
    
    static public func show() {
        let vc = SettingViewController()
        vc.hidesBottomBarWhenPushed = true
        topNavigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SettingViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 != 0, let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MineTableViewCell.self)) as? MineTableViewCell {
            cell.icon.isHidden = true
            cell.iconLeadingConstraint.constant = 0
            cell.subLabel.isHidden = true
            cell.indicatorView.isHidden = false
            cell.indicatorTralingConstraint.constant = 15
            if indexPath.row == 1 {
                cell.label.text = "修改密码"
            } else if indexPath.row == 3 {
                cell.label.text = "关于我们"
            } else {
                cell.label.text = "当前版本"
                cell.subLabel.text = Bundle.bundleShortVersion
                cell.subLabel.isHidden = false
                cell.indicatorView.isHidden = true
                cell.indicatorTralingConstraint.constant = 0
            }
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MineEmptyTableViewCell.self)) as? MineEmptyTableViewCell {
            cell.isUserInteractionEnabled = false
            return cell
        }
        return UITableViewCell()
    }
    
}

extension SettingViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 != 0 {
            return MineTableViewCell.height
        }
        return MineEmptyTableViewCell.height
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            ResetPasswordViewController.show()
        } else if indexPath.row == 3 {
            AboutUsViewController.show()
        }
    }
    
}

