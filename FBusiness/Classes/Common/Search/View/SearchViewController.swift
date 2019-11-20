//
//  SearchViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX

public class SearchViewController: BaseViewController {
    
    private lazy var searchBar: XSearchBar = {
        let sb = XSearchBar(frame: CGRect.zero)
        sb.becomeFirstResponder()
        sb.delegate = self
        sb.placeholder = "请输入关键字搜索"
        sb.showsCancelButton = true
        return sb
    }()
    
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
    private let vmodel = SearchVModel()
    private var pageNo: Int = 1
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        _init()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
    }
    
    public override func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool {
        return false
    }
    
    public override func loadingViewDidTapped(_ loadingView: XLoadingView) {
        loadingView.state = .loading
    }
    
    public override func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage? {
        return UIImage(named: "icon_search_empty", in: Bundle.currentCommon, compatibleWith: nil)
    }
    
    public override func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "服务器连接错误\n请检查网络设置~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        case .empty:
            return NSAttributedString(string: "抱歉，暂时未搜索到相关商品哦！", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
}

extension SearchViewController {
    
    private func _init() {
        navigationItemBackStyle = .none
        navigationItem.titleView = searchBar
        
        tableView.mj_footer.isHidden = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(0)
        }
    }
    
    private func _loadData(_ isRefresh: Bool) {
        guard let keyword = searchBar.text else { return }
        vmodel.fetch(keyword, isRefresh) { [weak self] (error) in
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

extension SearchViewController {
    
    static public func show() {
        let searchVC = SearchViewController()
        searchVC.hidesBottomBarWhenPushed = true
        topNavigationController?.pushViewController(searchVC, animated: true)
    }
    
}

extension SearchViewController: UITableViewDataSource {
    
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

extension SearchViewController: UITableViewDelegate {

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

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(GoodsTableHeaderView.self)), vmodel.datas.count != 0 {
            return headerView
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return vmodel.datas.count != 0 ? GoodsTableHeaderView.height : 0
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let _ = searchBar.text {
            loadingView.isHidden = true
            tableView.mj_header.beginRefreshing()
        }
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }

}

