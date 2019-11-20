//
//  AddressListViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster

public class AddressListViewController: BaseViewController {
    
    public typealias SelectedHandler = ((_ address: AddressModel) -> Void)
    
    private lazy var tableView: UITableView = {
        let tv = UITableView.default
        tv.register(UINib(nibName: "AddressListTableViewCell", bundle: Bundle(for: AddressListTableViewCell.self)), forCellReuseIdentifier: NSStringFromClass(AddressListTableViewCell.self))
        tv.mj_header = BaseMJRefreshHeader(refreshingBlock: { [weak self] () in
            self?._loadData()
        })
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    private var handler: SelectedHandler?
    private var vmodel = AddressVModel()

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
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
            return NSAttributedString(string: "当前还未添加任何地址，\n请点击添加~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
    
    public override func loadingViewTitleForButton(_ loadingView: XLoadingView) -> String? {
        return "添加地址"
    }
    
    public override func loadingViewButtonDidTapped(_ loadingView: XLoadingView) {
        if vmodel.datas.count == 0 {
            AddressAddViewController.show()
        } else {
            loadingView.isHidden = true
            tableView.mj_header.beginRefreshing()
        }
    }
}

extension AddressListViewController {
    
    private func _initUI() {
        navigationItem.title = "地址管理"
        
        navigationItem.rightBarButtonItem = rightBarButtonItem(image: UIImage(named: "icon_nav_add", in: Bundle.currentBase, compatibleWith: nil), size: CGSize(width: 28, height: 28)) { (_) in
            AddressAddViewController.show()
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.left.right.equalTo(0)
            $0.bottom.equalTo(-UIScreen.homeIndicatorMoreHeight)
        }
        
        tableView.mj_header.beginRefreshing()
        
        _ = NotificationCenter.default.rx.notification(AddressVModel.AddressChangeNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?._loadData()
            })
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

extension AddressListViewController {
    static public func show(with handler: SelectedHandler? = nil) {
        UserVModel.default.verify { (success) in
            if success {
                let vc = AddressListViewController()
                vc.handler = handler
                vc.hidesBottomBarWhenPushed = true
                topNavigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension AddressListViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vmodel.datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(AddressListTableViewCell.self)) as? AddressListTableViewCell {
            cell.model = vmodel.datas[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return handler == nil
    }
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertView = UIAlertController(title: "温馨提示", message: "确认删除改地址？", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            }))
            alertView.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { [weak self] (_) in
                guard let weakSelf = self else { return }
                weakSelf.startHUDAnimation()
                weakSelf.vmodel.delete(weakSelf.vmodel.datas[indexPath.row].addressId ?? "", { (_, error) in
                    weakSelf.stopHUDAnimation()
                    if error == nil {
                        Toast.show("删除成功")
                        if AddressVModel.default.currentAddress?.addressId == weakSelf.vmodel.datas[indexPath.row].addressId {
                            AddressVModel.default.currentAddress = nil
                        }
                        weakSelf.tableView.mj_header.beginRefreshing()
                    }
                })
            }))
            present(alertView, animated: true, completion: nil)
        }
    }

}

extension AddressListViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AddressListTableViewCell.height
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if handler != nil {
            navigationController?.popViewController(animated: true)
            handler?(vmodel.datas[indexPath.row])
        } else {
            AddressAddViewController.show(vmodel.datas[indexPath.row])
        }
    }
    
}

