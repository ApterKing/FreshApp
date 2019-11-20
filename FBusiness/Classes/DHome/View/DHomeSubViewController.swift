//
//  DHomeSubViewController.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/25.
//

import UIKit
import SwiftX
import SnapKit

class DHomeSubViewController: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let tv = UITableView.default
        tv.register(UINib(nibName: "DHomeTableViewCell", bundle: Bundle(for: DHomeTableViewCell.self)), forCellReuseIdentifier: NSStringFromClass(DHomeTableViewCell.self))
        tv.showsVerticalScrollIndicator = false
        tv.mj_header = BaseMJRefreshHeader(refreshingBlock: { [weak self] () in
            self?._loadData(true)
        })
        tv.mj_footer = BaseMJRefreshFooter(refreshingBlock: { [weak self] () in
            self?._loadData(false)
        })
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    var status: OrderModel.Status = .delivering
    
    private let vmodel = OrderDetailVModel()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
    }
    
    public override func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool {
        return true
    }
    
    public override func loadingViewDidTapped(_ loadingView: XLoadingView) {
        loadingView.isHidden = true
        tableView.mj_header.beginRefreshing()
    }
    
    public override func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage? {
        return status.emptyIcon
    }
    
    public override func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "服务器连接错误\n请检查网络设置~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        case .empty:
            return NSAttributedString(string: status.emptyPrompt, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
    
}

extension DHomeSubViewController {
    
    private func _initUI() {
        
        tableView.mj_footer.isHidden = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.left.right.equalTo(0)
            $0.bottom.equalTo(0)
        }
        
        tableView.mj_header.beginRefreshing()
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: "order_take_success"))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                guard let weakSelf = self else { return }
                weakSelf._loadData(true)
            })
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: "order_finish_success"))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                guard let weakSelf = self else { return }
                if weakSelf.status == .delivering {
                    weakSelf._loadData(true)
                }
            })
    }
    
    private func _loadData(_ isRefresh: Bool) {
        vmodel.fetch(status, isRefresh) { [weak self] (error) in
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

extension DHomeSubViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vmodel.datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DHomeTableViewCell.self)) as? DHomeTableViewCell {
            cell.selectionStyle = .none
            cell.status = self.status
            cell.model = vmodel.datas[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
}

extension DHomeSubViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DHomeTableViewCell.height
    }
    
    
    
}

