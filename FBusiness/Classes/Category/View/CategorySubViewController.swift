//
//  CategorySubViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class CategorySubViewController: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let tv = UITableView.default
        tv.register(GoodsTableHeaderView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(GoodsTableHeaderView.self))
        tv.register(GoodsMoreTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(GoodsMoreTableViewCell.self))
        tv.register(UINib(nibName: "GoodsTableViewCell", bundle: Bundle(for: GoodsTableViewCell.self)), forCellReuseIdentifier: NSStringFromClass(GoodsTableViewCell.self))
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
    
    private let vmodel = CategorySubVModel()
    // 当前一级分类
    var pcatelogId: String? {
        didSet {
            guard let pid = pcatelogId else { return }
            shouldSuspendSaleHeaderView = CategoryVModel.default.shouldShowSuspendSaleHeaderPrompt(levelOne: pid)
        }
    }
    var catelogId: String?  // 当前二级分类

    private var shouldSuspendSaleHeaderView: Bool = false

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
        return UIImage(named: "icon_order_empty", in: Bundle.currentBase, compatibleWith: nil)
    }
    
    public override func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "服务器连接错误\n请检查网络设置~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        case .empty:
            return NSAttributedString(string: "还没有该分类的商品哦，\n去看看其他分类吧。", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
}

extension CategorySubViewController {
    
    private func _initUI() {
        tableView.mj_footer.isHidden = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(0)
        }
        
        tableView.mj_header.beginRefreshing()
    }
    
    private func _loadData(_ isRefresh: Bool) {
        guard let catelogId = self.catelogId else { return }
        vmodel.fetch(catelogId, isRefresh) { [weak self] (error) in
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
            loadingView.state = .error
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

extension CategorySubViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vmodel.datas.count + (vmodel.showMoreCell ? 1 : 0)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if vmodel.showMoreCell && indexPath.row == vmodel.datas.count {
            if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(GoodsMoreTableViewCell.self)) as? GoodsMoreTableViewCell {
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(GoodsTableViewCell.self)) as? GoodsTableViewCell {
                cell.sellProgressShouldHidden = true
                cell.model = vmodel.datas[indexPath.row]
                return cell
            }
        }
        return UITableViewCell()
    }
    
}

extension CategorySubViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if vmodel.showMoreCell && indexPath.row == vmodel.datas.count {
            return GoodsMoreTableViewCell.height
        }
        return GoodsTableViewCell.height
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if vmodel.showMoreCell && indexPath.row == vmodel.datas.count { return }
        GoodsDetailViewController.show(with: vmodel.datas[indexPath.row].productId)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(GoodsTableHeaderView.self)), shouldSuspendSaleHeaderView == true {
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return shouldSuspendSaleHeaderView ? GoodsTableHeaderView.height : 0
    }
    
}
