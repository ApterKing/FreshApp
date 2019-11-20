//
//  CouponViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster

class CouponViewController: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let tv = UITableView.default
        tv.register(UINib(nibName: "CouponTableViewCell", bundle: Bundle(for: CouponTableViewCell.self)), forCellReuseIdentifier: NSStringFromClass(CouponTableViewCell.self))
        tv.mj_header = BaseMJRefreshHeader(refreshingBlock: { [weak self] () in
            self?._loadData()
        })
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    private var isSelectAddress: Bool = false
    private var vmodel = CouponVModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
    }
    
    public override func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool {
        return false
    }
    
    public override func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage? {
        return UIImage(named: "icon_order_empty", in: Bundle.currentBase, compatibleWith: nil)
    }
    
    public override func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "服务器连接错误\n请检查网络设置~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        case .empty:
            return NSAttributedString(string: "当前还未获得任何优惠券哦~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
}

extension CouponViewController {
    
    private func _initUI() {
        navigationItem.title = "我的优惠券"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.left.right.equalTo(0)
            $0.bottom.equalTo(-UIScreen.homeIndicatorMoreHeight)
        }
        
        tableView.mj_header.beginRefreshing()
    }
    
    private func _loadData() {
        vmodel.fetch { [weak self] (error) in
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
        }
    }
    
    private func _processResult() {
        tableView.reloadData()
        tableView.mj_header.endRefreshing()
        
        if vmodel.datas.count == 0 {
            loadingView.state = .empty
            loadingView.isHidden = false
        } else {
            loadingView.isHidden = true
        }
    }
    
}

extension CouponViewController {
    static public func show(_ isSelectAddress: Bool = false) {
        UserVModel.default.verify { (success) in
            if success {
                let vc = CouponViewController()
                vc.hidesBottomBarWhenPushed = true
                topNavigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension CouponViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vmodel.datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CouponTableViewCell.self)) as? CouponTableViewCell {
            cell.selectionStyle = .none
            cell.model = vmodel.datas[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }

}

extension CouponViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CouponTableViewCell.height
    }
    
}

