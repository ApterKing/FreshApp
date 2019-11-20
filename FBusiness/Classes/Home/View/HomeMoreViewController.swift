//
//  HomeMoreViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class HomeMoreViewController: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let tv = UITableView.default
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
    
    private let vmodel = HomeMoreVModel()
    var recommendId: String?
    var titleString: String = "" {
        didSet {
            navigationItem.title = titleString
        }
    }

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
        return UIImage(named: "icon_search_empty", in: Bundle.currentCommon, compatibleWith: nil)
    }
    
    public override func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "服务器连接错误\n请检查网络设置~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        case .empty:
            return NSAttributedString(string: "抱歉，暂时没有更多相关商品哦！", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
}

extension HomeMoreViewController {
    
    private func _initUI() {
        tableView.mj_footer.isHidden = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.left.right.equalTo(0)
            $0.bottom.equalTo(-UIScreen.homeIndicatorMoreHeight)
        }
        
        tableView.mj_header.beginRefreshing()
    }
    
    private func _loadData(_ isRefresh: Bool) {
        guard let recommendId = self.recommendId else { return }
        vmodel.fetch(recommendId, isRefresh) { [weak self] (error) in
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

extension HomeMoreViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vmodel.datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(GoodsTableViewCell.self)) as? GoodsTableViewCell {
            cell.sellProgressShouldHidden = true
            cell.model = vmodel.datas[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
}

extension HomeMoreViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GoodsTableViewCell.height
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        GoodsDetailViewController.show(with: vmodel.datas[indexPath.row].productId)
    }
    
}
