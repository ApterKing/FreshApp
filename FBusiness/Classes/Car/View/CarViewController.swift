//
//  CarViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster

public class CarViewController: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let tv = UITableView.default
        tv.register(UINib(nibName: "CarTableViewCell", bundle: Bundle.currentCar), forCellReuseIdentifier: NSStringFromClass(CarTableViewCell.self))
        tv.showsVerticalScrollIndicator = false
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    private let headerView = CarTableViewHeaderView.loadFromXib()
    private let bottomView = CarBottomView.loadFromXib()
    
    private var datas: [CarModel] = []
    private var hasSelectedAll: Bool = false

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 如果是第一次进入，这里需要默认全选已添加的商品
        if !hasSelectedAll {
            let tmpDatas = CarVModel.default.datas.value.map { (model) -> CarModel in
                model.isChecked = (model.stock ?? 0) > model.count && model.productStatus ?? .normal == .normal
                return model
            }
            // 如果第一次进入没有商品，那么还是保持为第一次为hasSelectedAll = false
            if tmpDatas.count != 0 {
                hasSelectedAll = true
                CarVModel.default.datas.accept(tmpDatas)
            }
        }
        
        if UserVModel.default.isLogined {
            if datas.count == 0 {
                loadingView.isHidden = false
                loadingView.state = .empty
            } else {
                loadingView.isHidden = true
            }
            headerView.addressModel = AddressVModel.default.currentAddress
            CarVModel.default.fetch(nil)

            bottomView.refreshDeliveryTime()
        } else {
            loadingView.isHidden = false
            loadingView.state = .empty
            headerView.addressModel = nil
        }
        tableView.reloadData()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingView.frame = tableView.frame
    }
    
    public override func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool {
        return true
    }
    
    public override func loadingViewDidTapped(_ loadingView: XLoadingView) {
        if !UserVModel.default.isLogined {
            LoginViewController.show()
        }
    }
    
    public override func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage? {
        return UIImage(named: "icon_order_empty", in: Bundle.currentBase, compatibleWith: nil)
    }
    
    public override func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "服务器连接错误\n请检查网络设置~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        case .empty:
            return NSAttributedString(string: UserVModel.default.isLogined ? "购物车控控如也\n赶紧去逛逛吧" : "请先登录哟~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
    
}

extension CarViewController {
    
    private func _initUI() {
        isNavigationBarHiddenIfNeeded = true

        view.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.left.right.equalTo(0)
            $0.height.equalTo(headerView.height)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.left.bottom.right.equalTo(0)
            $0.height.equalTo(45)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.left.right.equalTo(0)
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        _ = headerView.settlementButton.rx.controlEvent(.touchUpInside)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                guard let weakSelf = self else { return }
                UserVModel.default.verify({ (success) in
                    if success {
                        weakSelf.headerView.isSettlement = !weakSelf.headerView.isSettlement
                        weakSelf.bottomView.isSettlement = weakSelf.headerView.isSettlement
                        
                        if weakSelf.headerView.isSettlement {
                            let models = CarVModel.default.datas.value
                            for model in models {
                                if (model.productStatus ?? .normal != .normal || model.stock ?? 0 == 0) && (model.isChecked ?? false == true) {
                                    model.isChecked = false
                                }
                            }
                            
                            CarVModel.default.datas.accept(models)
                        } else {
                            weakSelf.tableView.reloadData()
                        }
                    }
                })
            })

        _ = CarVModel.default.datas.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (datas) in
                guard let weakSelf = self else { return }
                if datas.count == 0 {
                    weakSelf.loadingView.isHidden = false
                    weakSelf.loadingView.state = .empty
                } else {
                    weakSelf.loadingView.isHidden = true
                }
                weakSelf.datas = datas
                weakSelf.bottomView.isCheckedAll = CarVModel.default.isCheckedAll
                weakSelf.bottomView.price = CarVModel.default.checkedPrice()
                weakSelf.tableView.reloadData()
            })
        
        _ = NotificationCenter.default.rx.notification(Constants.notification_user_logout)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.hasSelectedAll = false
            })
        
        _ = NotificationCenter.default.rx.notification(Constants.notification_tabbar_selectedIndex_changed)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                if let selectedIndex = notification.object as? Int, selectedIndex == 2 {
                    CategoryVModel.default.fetch({ (_) in
                        self?.tableView.reloadData()
                    })
                }
            })
    }
    
}

extension CarViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CarTableViewCell.self)) as? CarTableViewCell {
            cell.separatorLine.isHidden = indexPath.row == datas.count - 1
            let model = datas[indexPath.row]
            cell.model = model
            cell.isUserInteractionEnabled = true
            if model.productStatus ?? .normal != .normal || model.stock ?? 0 == 0 {
                cell.isUserInteractionEnabled = !headerView.isSettlement
            }
            if CategoryVModel.default.shouldShowSuspendSalePrompt(levelOne: model.pCatelogId) {
                cell.isUserInteractionEnabled = false
            }
            cell.handler = { (add, model) in
                if add {
                    CarVModel.default.checkStock(carModel: model, complection: { (success) in
                        if success {
                            model.count += 1
                            CarVModel.default.add(model.productId, 1, true, false, nil)
                        }
                    })
                } else {
                    if model.count > 1 {
                        model.count -= 1
                        CarVModel.default.edit([model.cartId: model.count])
                    } else {  // 删除
                        let cartIds = [model.cartId]
                        topViewController?.startHUDAnimation()
                        CarVModel.default.delete(cartIds, false) { (baseModel, error) in
                            topViewController?.stopHUDAnimation()
                            CarVModel.default.fetch({ (_) in
                            })
                        }
                    }
                }
                tableView.reloadData()
            }
            return cell
        }
        return UITableViewCell()
    }
    
}

extension CarViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CarTableViewCell.height
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = datas[indexPath.row]
        guard !CategoryVModel.default.shouldShowSuspendSalePrompt(levelOne: model.pCatelogId) else {
            return
        }
        model.isChecked = !(model.isChecked ?? false)
        CarVModel.default.datas.accept(datas)
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            let alertView = UIAlertController(title: "温馨提示", message: "确认删除该商品？", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            }))
            alertView.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { [weak self] (_) in
                guard let weakSelf = self else { return }
                weakSelf.startHUDAnimation()
                let model = weakSelf.datas[indexPath.row]
                let cartIds = [model.cartId]
                CarVModel.default.delete(cartIds, false) { (baseModel, error) in
                    CarVModel.default.fetch({ (_) in
                        topViewController?.stopHUDAnimation()
                    })
                }
            }))
            present(alertView, animated: true, completion: nil)
        }
    }
    
}
