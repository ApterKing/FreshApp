//
//  AboutUsViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class AboutUsViewController: BaseViewController {

    private lazy var tableView: UITableView = {
        let tv = UITableView.default
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

extension AboutUsViewController {
    
    private func _initUI() {
        navigationItem.title = "关于我们"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(0)
        }
    }
    
}

extension AboutUsViewController {
    
    static public func show() {
        let vc = AboutUsViewController()
        vc.hidesBottomBarWhenPushed = true
        topNavigationController?.pushViewController(vc, animated: true)
    }
    
}

extension AboutUsViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 != 0, let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MineTableViewCell.self)) as? MineTableViewCell {
            cell.icon.isHidden = true
            cell.iconLeadingConstraint.constant = 0
            cell.subLabel.isHidden = false
            cell.indicatorView.isHidden = false
            cell.indicatorTralingConstraint.constant = 15
            if indexPath.row == 1 {
                cell.label.text = "客服电话"
                cell.subLabel.text = "0825-2323198"
            } else if indexPath.row == 3 {
                cell.label.text = "公司地址"
                cell.subLabel.text = "四川省遂宁市经济技术开发区翠屏街64栋1号"
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

extension AboutUsViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 != 0 {
            return MineTableViewCell.height
        }
        return MineEmptyTableViewCell.height
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            guard let url = URL(string: "telprompt://0825-2323198)")  else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}

