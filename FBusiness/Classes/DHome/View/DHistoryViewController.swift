//
//  DHistoryViewController.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/26.
//

import UIKit
import SwiftX

class DHistoryViewController: BaseViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    private let vmodel = DHistoryVModel()
    private let loginVModel = DLoginVModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
        _loadStatistic()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingView.frame = tableView.frame
    }
    
    public override func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool {
        return true
    }
    
    public override func loadingViewDidTapped(_ loadingView: XLoadingView) {
        loadingView.isHidden = true
        tableView.mj_header.beginRefreshing()
    }
    
    public override func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage? {
        return UIImage(named: "icon_order_empty", in: Bundle.currentBase, compatibleWith: nil)
    }
    
    public override func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "服务器连接错误\n请检查网络设置~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        case .empty:
            return NSAttributedString(string: "当前还没有配送订单哦~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
    
}

extension DHistoryViewController {
    
    private func _initUI() {
        navigationItem.title = "配送历史"
        nameLabel.text = UserVModel.default.currentUser?.userName ?? ""
        
        let options: [UIControlStateOption] = [.title("切换账号", UIColor(hexColor: "#333333"), .normal),
                                               .title("切换账号", UIColor(hexColor: "#666666"), .disabled),
                                               .title("切换账号", UIColor(hexColor: "#333333").withAlphaComponent(0.7), .highlighted)
                                            ]
        navigationItem.rightBarButtonItem = customBarButtonItem(options: options, size: CGSize(width: 60, height: 44), isBackItem: false, left: false, handler: { [weak self] (_) in
            let alertController = UIAlertController(title: "温馨提示", message: "确认切换当前用户？", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (_) in
                self?.startHUDAnimation()
                self?.loginVModel.logout({
                    self?.stopHUDAnimation()
                    UIApplication.shared.keyWindow?.rootViewController = XBaseNavigationController(rootViewController: DLoginViewController(nibName: "DLoginViewController", bundle: Bundle.currentDLogin))
                })
            }))
            currentViewController?.present(alertController, animated: true, completion: nil)
        })
        
        tableView.register(UINib(nibName: "DHistoryTableViewCell", bundle: Bundle.currentDHome), forCellReuseIdentifier: NSStringFromClass(DHistoryTableViewCell.self))
        tableView.mj_header = BaseMJRefreshHeader(refreshingBlock: { [weak self] () in
            self?._loadData(true)
        })
        tableView.mj_footer = BaseMJRefreshFooter(refreshingBlock: { [weak self] () in
            self?._loadData(false)
        })
        tableView.mj_footer.isHidden = true
        tableView.mj_header.beginRefreshing()
    }
    
    private func _loadStatistic() {
        vmodel.statistic { [weak self] (model, error) in
            if let model = model {
                self?.historyLabel.text = "\(model.allCount)"
                self?.monthLabel.text = "\(model.monthCount)"
            }
        }
    }
    
    private func _loadData(_ isRefresh: Bool) {
        vmodel.fetch(isRefresh) { [weak self] (error) in
            if error == nil {
                self?._processResult()
            } else {
                self?._processError(error!)
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

extension DHistoryViewController {
    
    static public func show() {
        let vc = DHistoryViewController(nibName: "DHistoryViewController", bundle: Bundle.currentDHome)
        vc.hidesBottomBarWhenPushed = true
        currentNavigationController?.pushViewController(vc, animated: true)
    }
    
}

extension DHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vmodel.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DHistoryTableViewCell.self)) as? DHistoryTableViewCell {
            cell.selectionStyle = .none
            cell.model = vmodel.datas[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
}

extension DHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DHistoryTableViewCell.height
    }
    
}
