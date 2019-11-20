//
//  FlowCashViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster

class FlowCashViewController: BaseViewController {

    @IBOutlet weak var flowCashLabel: UILabel!
    @IBOutlet weak var flowStatusLabel: UILabel!
    
    @IBOutlet weak var withdrawalButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var applyView: FlowCashApplyView = {
        let view = FlowCashApplyView.loadFromXib()
        return view
    }()
    
    private let vmodel = FlowCashVModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingView.frame = tableView.frame
    }
    
    public override func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool {
        return true
    }
    
    public override func loadingViewDidTapped(_ loadingView: XLoadingView) {
        loadingView.isHidden = false
        _loadData(true)
    }
    
    public override func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage? {
        return UIImage(named: "icon_order_empty", in: Bundle.currentBase, compatibleWith: nil)
    }
    
    public override func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "服务器连接错误\n请检查网络设置~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        case .empty:
            return NSAttributedString(string: "当前还没有收入流水哦~\n快去邀请用户吧", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }


    @IBAction func buttonAction(_ sender: UIButton) {
        if sender.tag == 0 {
            RewardIntroViewController.show()
        } else if sender.tag == 1 {
            if UserVModel.default.currentUser?.alipay == nil {
                FlowCashBindViewController.show()
            } else if (UserVModel.default.currentUser?.userWithdraw ?? 0) == 0 {
                applyView.show()
            } else {
                Toast.show("您有一个提现申请，正在审核中")
            }
        } else {
            FlowCashBindViewController.show()
        }
    }
    
}

extension FlowCashViewController {
    
    private func _initUI() {
        navigationItem.title = "收入流水"
        
        tableView.register(UINib(nibName: "FlowCashTableViewCell", bundle: Bundle.currentMine), forCellReuseIdentifier: NSStringFromClass(FlowCashTableViewCell.self))
        tableView.mj_header = BaseMJRefreshHeader(refreshingBlock: { [weak self] () in
            self?._loadData(true)
        })
        tableView.mj_footer = BaseMJRefreshFooter(refreshingBlock: { [weak self] () in
            self?._loadData(false)
        })
        tableView.mj_footer.isHidden = true
        
        Theme.decorate(button: withdrawalButton, font: UIFont.systemFont(ofSize: 15), color: UIColor(hexColor: "#ED9E32"), cornerRadius: 14)
        Theme.decorate(button: accountButton, font: UIFont.systemFont(ofSize: 15), color: UIColor(hexColor: "#ED9E32"), cornerRadius: 14)
        
        applyView.dismiss()
        applyView.handler = { [weak self] (money) in
            self?._apply(money)
        }
        
        tableView.mj_header.beginRefreshing()
        
        _resetFlowCashLabel()
        UserVModel.default.userInfoRefresh { [weak self] (userInfo, _) in
            self?._resetFlowCashLabel()
        }
    }
    
    private func _resetFlowCashLabel() {
        flowCashLabel.text = String(format: "￥%.2f", UserVModel.default.currentUser?.userBalance ?? 0)
        if let withdraw = UserVModel.default.currentUser?.userWithdraw, withdraw != 0 {
            flowStatusLabel.text = String(format: "(提现中:%.1f)", withdraw)
        } else {
            flowStatusLabel.text = ""
        }
    }
    
    private func _loadData(_ isRefresh: Bool) {
        if isRefresh {
            UserVModel.default.userInfoRefresh { [weak self] (userInfo, _) in
                self?._resetFlowCashLabel()
            }
        }
        vmodel.fetch(isRefresh) { [weak self] (error) in
            if error == nil {
                self?._processResult()
            } else {
                self?._processError(error!)
            }
        }
    }
    
    private func _apply(_ money: Float) {
        startHUDAnimation()
        vmodel.apply(money) { [weak self] (data, error) in
            self?.stopHUDAnimation()
            if data != nil {
                let currentUser = UserVModel.default.currentUser
                currentUser?.userWithdraw = money
                UserVModel.default.currentUser = currentUser
                self?._resetFlowCashLabel()
                Toast.show("申请成功，请耐心等待")
            }
        }
    }
    
    private func _processError(_ error: HttpError) {
        if error != .errorCanceled {
            _processResult()
            loadingView.state = (error == HttpError.errorNull || error == HttpError.error204) ? .empty : .error
            loadingView.isHidden = false
            tableView.mj_footer.isHidden = true
        }
    }
    
    private func _processResult() {
        tableView.reloadData()
        tableView.mj_header.endRefreshing()
        tableView.mj_footer.endRefreshing()
        tableView.mj_footer.isHidden = false
        if vmodel.hasMore {
            tableView.mj_footer.resetNoMoreData()
        } else {
            tableView.mj_footer.endRefreshingWithNoMoreData()
        }
        
        if vmodel.datas.count == 0 {
            loadingView.state = .empty
            loadingView.isHidden = false
            tableView.mj_footer.isHidden = true
        } else {
            loadingView.isHidden = true
            tableView.mj_footer.isHidden = !vmodel.hasMore
        }
    }
}

extension FlowCashViewController {
    
    static public func show() {
        UserVModel.default.verify { (success) in
            if success {
                let vc = FlowCashViewController(nibName: "FlowCashViewController", bundle: Bundle.currentMine)
                vc.hidesBottomBarWhenPushed = true
                topNavigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

extension FlowCashViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vmodel.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(FlowCashTableViewCell.self)) as? FlowCashTableViewCell {
            cell.selectionStyle = .none
            cell.model = vmodel.datas[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
}

extension FlowCashViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FlowCashTableViewCell.calculate(with: vmodel.datas[indexPath.row])
    }
    
}
