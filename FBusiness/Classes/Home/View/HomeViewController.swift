//
//  HomeViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import SnapKit
import Kingfisher

public class HomeViewController: BaseViewController {
    
    private let navigationBarView = HomeNavigationBarView.loadFromXib()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView.default
        tv.frame = CGRect(x: 0, y: navigationBarView.height, width: UIScreen.width, height: UIScreen.height - UIScreen.navigationBarHeight - UIScreen.tabBarHeight)
        tv.register(UINib(nibName: "HomeWheelTableViewCell", bundle: Bundle.currentHome), forCellReuseIdentifier: NSStringFromClass(HomeWheelTableViewCell.self))
        tv.register(UINib(nibName: "HomeCategoryTableViewCell", bundle: Bundle.currentHome), forCellReuseIdentifier: NSStringFromClass(HomeCategoryTableViewCell.self))
        tv.register(UINib(nibName: "HomeLabelTableViewCell", bundle: Bundle.currentHome), forCellReuseIdentifier: NSStringFromClass(HomeLabelTableViewCell.self))
        tv.register(UINib(nibName: "HomeMoreTableViewCell", bundle: Bundle.currentHome), forCellReuseIdentifier: NSStringFromClass(HomeMoreTableViewCell.self))
        tv.register(UINib(nibName: "HomeSpecialTableViewCell", bundle: Bundle(for: HomeSpecialTableViewCell.self)), forCellReuseIdentifier: NSStringFromClass(HomeSpecialTableViewCell.self))
        tv.register(UINib(nibName: "HomeSeckillTableViewCell", bundle: Bundle(for: HomeSeckillTableViewCell.self)), forCellReuseIdentifier: NSStringFromClass(HomeSeckillTableViewCell.self))
        tv.register(UINib(nibName: "GoodsTableViewCell", bundle: Bundle(for: GoodsTableViewCell.self)), forCellReuseIdentifier: NSStringFromClass(GoodsTableViewCell.self))
        tv.mj_header = BaseMJRefreshHeader(refreshingBlock: { [weak self] () in
            self?._refresh()
        })
        tv.showsVerticalScrollIndicator = false
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    private var vmodel = HomeVModel()
    
    private let fixedCount: Int = 3

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarView.titleLabel.text = CityVModel.default.currentCityName
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingView.frame = tableView.frame
        navigationBarView.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.navigationBarHeight)
    }

    public override func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool {
        return true
    }
    
    public override func loadingViewDidTapped(_ loadingView: XLoadingView) {
        _refresh(true)
    }
    
    public override func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage? {
        return UIImage(named: "icon_order_canceled_empty", in: Bundle.currentBase, compatibleWith: nil)
    }
    
    public override func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "服务器连接错误\n请检查网络设置~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        case .empty:
            return NSAttributedString(string: "获取列表数据失败，点击重试", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
    
}

extension HomeViewController {
    
    private func _initUI() {
        isNavigationBarHiddenIfNeeded = true

        view.addSubview(navigationBarView)
        
        view.addSubview(tableView)
        _refresh(true)
        
        _ = NotificationCenter.default.rx.notification(Constants.notification_city_changed)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.navigationBarView.titleLabel.text = CityVModel.default.currentCity?.cityName
                self?._refresh()
            })
    }
    
    @objc private func _refresh(_ shouldShowloadingView: Bool = false) {
        if shouldShowloadingView {
            loadingView.state = .loading
            loadingView.isHidden = false
        }
        vmodel.fetch { [weak self] (isRecommend, error) in
            guard let weakSelf = self else { return }
            weakSelf.tableView.mj_header.endRefreshing()
            weakSelf.tableView.reloadData()
            weakSelf.loadingView.isHidden = true
            weakSelf.loadingView.state = .success
        }
    }
    
    private func _goToMoreViewController(_ titleString: String, _ recommendId: String) {
        let vc = HomeMoreViewController()
        vc.titleString = titleString
        vc.recommendId = recommendId
        vc.hidesBottomBarWhenPushed = true
        topNavigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return fixedCount + vmodel.recommends.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {  // banner
            return vmodel.topDatas.count == 0 ? 0 : 1
        } else if section == 1 {  // 分类
            return vmodel.categoryDatas.count == 0 ? 0 : 1
        } else if section == 2 {  // 特价
            return vmodel.specialDatas.count == 0 ? 0 : 1
        } else {
            let count = (vmodel.recommends[section - fixedCount].products ?? []).count
            return count == 0 ? 0 : 1
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {  // banner
            if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(HomeWheelTableViewCell.self)) as? HomeWheelTableViewCell {
                cell.selectionStyle = .none
                cell.configs = vmodel.topDatas
                return cell
            }
        } else if indexPath.section == 1 {   // 分类
            if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(HomeCategoryTableViewCell.self)) as? HomeCategoryTableViewCell {
                cell.selectionStyle = .none
                cell.categories = vmodel.categoryDatas
                return cell
            }
        } else if indexPath.section == 2 {  // 特价
            if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(HomeSpecialTableViewCell.self)) as? HomeSpecialTableViewCell {
                cell.selectionStyle = .none
                cell.products = vmodel.specialDatas
                return cell
            }
        } else {
            let recommend = vmodel.recommends[indexPath.section - fixedCount]
            if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(HomeSeckillTableViewCell.self)) as? HomeSeckillTableViewCell {
                cell.selectionStyle = .none
                cell.recommend = recommend
                return cell
            }
        }
        return UITableViewCell()
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return HomeWheelTableViewCell.height
        } else if indexPath.section == 1 {
            return HomeCategoryTableViewCell.calculateHeight(vmodel.categoryDatas)
        } else if indexPath.section == 2 {  // 特价
            return HomeSpecialTableViewCell.height
        } else {
            return HomeSeckillTableViewCell.height
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


