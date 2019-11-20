//
//  OrderDetailViewController.swift
//  FBusiness
//
//

import UIKit
import Toaster
import SwiftX

public class OrderDetailViewController: BaseViewController {
    
    // view0
    @IBOutlet weak var statusImgv: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    // view2
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var moreHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var moreButton: UIButton!
    
    // view3
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    
    // view4
    @IBOutlet weak var couponView: UIView!
    @IBOutlet weak var couponHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var couponLabel: UILabel!
    
    // view6
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
    // view8
    @IBOutlet weak var deliveryTimeLabel: UILabel!
    
    // view9
    @IBOutlet weak var addressInfoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var namePhoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressHeightConstraint: NSLayoutConstraint!
    
    // view11
    @IBOutlet weak var SNoLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    
    // view12
    @IBOutlet weak var orderTimeLabel: UILabel!
    
    // view13
    @IBOutlet weak var takeOrderView: UIView!
    @IBOutlet weak var takeOrderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var takeOrderLabel: UILabel!
    
    // view14
    @IBOutlet weak var payTypeView: UIView!
    @IBOutlet weak var payTypeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var payTypeLabel: UILabel!
    
    // view15
    @IBOutlet weak var memoTagLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView0: UIView!
    
    @IBOutlet weak var bottomView1: UIView!
    @IBOutlet weak var bottomView1WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomButton1: UIButton!
    @IBOutlet weak var deadServiceLabel: UILabel!
    
    private let payWayView = OrderPayWayView.loadFromXib()
    
    private var orderId: String?
    private var detailVModel = OrderDetailVModel()
    private var orderVModel = OrderVModel()
    private var model: OrderDetailModel?
    private var products: [ProductModel] = []
    private var isExpanded: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
        _loadData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
    }
    
    @IBAction func copyAction(_ sender: UIButton) {
        guard let SNo = model?.order?.orderSNo else { return }
        let pasteboard = UIPasteboard.general
        pasteboard.string = SNo
        Toast.show("复制成功")
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        if sender.tag == 0 {  // 更多
            isExpanded = !isExpanded
            _resetData()
        } else if sender.tag == 1 {  // 取消订单
            let status = OrderModel.Status(rawValue: model?.order?.orderStatus ?? "unpaid") ?? .unpaid
            if status == .undeliver, let deadline = CityVModel.default.currentCity?.config?.orderDeadline, let order = self.model?.order {
                // 下单日期+deadline
                let deadlineTime = "\(Date(timeIntervalSince1970: order.orderTime / 1000).format(to: "yyyy-MM-dd")) \(deadline)"
                if Date().format(to: "yyyy-MM-dd HH:mm") > deadlineTime {
                    Toast.show("订单已过取消时间")
                    return
                }
            }
            let alertController = UIAlertController(title: "温馨提示", message: "确定要取消该笔订单？", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { [weak self] (_) in
                self?._cancel()
            }))
            present(alertController, animated: true, completion: nil)
        } else {  // 功能按钮
            let status = OrderModel.Status(rawValue: model?.order?.orderStatus ?? "unpaid") ?? .unpaid
            switch status {
            case .unpaid:  // 调用支付
                //bottomButton1.setTitle("立即支付", for: .normal)
                payWayView.show(with: model?.order?.orderMoney ?? 0)
                break
            case .delivering: // 联系配送员
                guard let deliver = self.model?.delivery, let url = URL(string: "telprompt://\(deliver.userPhone ?? "")")  else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            default:
                break
            }
        }
    }
    
    public override func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool {
        return true
    }
    
    public override func loadingViewDidTapped(_ loadingView: XLoadingView) {
        _loadData()
    }
    
    public override func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage? {
        return UIImage(named: "icon_order_canceled_empty", in: Bundle.currentBase, compatibleWith: nil)
    }
    
    public override func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "服务器连接错误\n请检查网络设置~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        case .empty:
            return NSAttributedString(string: "获取订单详情失败，点击重试", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
}

extension OrderDetailViewController {
    
    static public func show(_ orderId: String) {
        UserVModel.default.verify { (success) in
            if success {
                let vc = OrderDetailViewController(nibName: "OrderDetailViewController", bundle: Bundle.currentCommon)
                vc.orderId = orderId
                vc.hidesBottomBarWhenPushed = true
                topNavigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension OrderDetailViewController {
    
    private func _initUI() {
        navigationItem.title = "订单详情"
        
        tableView.register(UINib(nibName: "OrderProductTableViewCell", bundle: Bundle.currentCommon), forCellReuseIdentifier: NSStringFromClass(OrderProductTableViewCell.self))
        
        copyButton.setTitleColor(UIColor(hexColor: "#66B30C"), for: .normal)
        copyButton.backgroundColor = UIColor.clear
        copyButton.layer.cornerRadius = 5
        copyButton.layer.borderColor = UIColor(hexColor: "#66B30C").cgColor
        copyButton.layer.borderWidth = 1.5
        copyButton.clipsToBounds = true
        
        payWayView.dismiss()
        payWayView.handler = { [weak self] (type) in
            guard let weakSelf = self, let orderId = weakSelf.model?.order?.orderId else { return }
            topViewController?.startHUDAnimation()
            weakSelf.orderVModel.pay(orderId, type, { (payModel, error) in
                topViewController?.stopHUDAnimation()
                if let model = payModel {
                    PayVModel.default.pay(with: type, model: model, topNavigationController: nil, completion: { [weak self] (success) in
                        if success {
                            self?._loadData(false)
                        }
                    })
                }
            })
        }
        
        // 通知消息发送的订单状态改变
        _ = NotificationCenter.default.rx.notification(Constants.notification_order_status_changed)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?._loadData(false)
            })
    }
    
    private func _loadData(_ shouldShowLoading: Bool = true) {
        guard let orderId = self.orderId else { return }
        if shouldShowLoading {
            loadingView.state = .loading
            loadingView.isHidden = false
        }
        detailVModel.fetch(orderId) { [weak self] (model, error) in
            guard let weakSelf = self else { return }
            weakSelf.stopHUDAnimation()
            if let model = model {
                weakSelf.loadingView.isHidden = true
                weakSelf.loadingView.state = .success
                weakSelf.model = model
                weakSelf._resetData()
            } else {
                weakSelf.loadingView.state = .error
            }
        }
    }
    
    private func _cancel() {
        guard let orderId = self.orderId else { return }
        startHUDAnimation()
        orderVModel.cancel(orderId) { [weak self] (baseModel, error) in
            if error == nil {
                self?._loadData(false)
                NotificationCenter.default.post(name: Constants.notification_order_canceled, object: nil)
            } else {
                self?.stopHUDAnimation()
            }
        }
    }
    
    private func _resetData() {
        guard let model = self.model, let order = model.order, let addressInfo = model.addressInfo else { return }
        
        let status = OrderModel.Status(rawValue: model.order?.orderStatus ?? "unpaid") ?? .unpaid
        statusImgv.image = status.statusIcon
        statusLabel.text = status.statusPrompt
        
        var contentHeight: CGFloat = 10
        products = model.products ?? []
        tableHeightConstraint.constant = CGFloat(isExpanded ? products.count : min(products.count, 2)) * OrderProductTableViewCell.height
        contentHeight += tableHeightConstraint.constant
        tableView.reloadData()

        if products.count <= 2 {
            moreView.isHidden = true
            moreHeightContraint.constant = 0
        } else {
            moreView.isHidden = false
            moreHeightContraint.constant = 60
        }
        moreButton.setImage(UIImage(named: isExpanded ? "icon_pick_up" : "icon_expand_more", in: Bundle.currentBase, compatibleWith: nil), for: .normal)
        contentHeight += moreHeightContraint.constant
        
        deliveryFeeLabel.text = order.deliverFee != 0 ? String(format: "￥%.2f", order.deliverFee) : "免配送费"
        contentHeight += 40
        
        // 优惠
        couponLabel.text = String(format: "-￥%.2f", (order.orderOrgMoney ?? order.orderMoney) - order.orderMoney)
        couponView.isHidden = false
        contentHeight += 40
        
        // 收货码
        codeLabel.text = order.orderCheckCode ?? ""
        priceLabel.text = String(format: "￥%.2f", order.total)
        contentHeight += 40
        
        contentHeight += 10
        
        // 送达时间
        let deliveryStartTime = Date(timeIntervalSince1970: order.deliveryStartTime / 1000).format(to: "MM月dd日 HH:mm")
        let deliveryEndTime = Date(timeIntervalSince1970: order.deliveryEndTime / 1000).format(to: "HH:mm")
        deliveryTimeLabel.text = "\(deliveryStartTime)-\(deliveryEndTime)"
        contentHeight += 40
        
        // 收货信息
        namePhoneLabel.text = "\(addressInfo.userName)  \(addressInfo.userPhone)"
        addressLabel.text = "\(addressInfo.area ?? "")\(addressInfo.userAddress ?? "")"
        let addressHeight = addressLabel.text?.heightWith(font: addressLabel.font, limitWidth: UIScreen.width - 110) ?? 16
        addressHeightConstraint.constant = addressHeight
        addressInfoHeightConstraint.constant = 44 + addressHeight
        contentHeight += addressInfoHeightConstraint.constant
        
        // 订单编号
        SNoLabel.text = order.orderSNo
        
        // 下单时间
        orderTimeLabel.text = "\(Date(timeIntervalSince1970: order.orderTime / 1000).format(to: "yyyy-MM-dd HH:mm:ss"))"
        contentHeight += 40
        
        // 接单时间
        if let doneTime = order.doneTime {
            takeOrderLabel.text = "\(Date(timeIntervalSince1970: doneTime / 1000).format(to: "yyyy-MM-dd HH:mm:ss"))"
        } else {
            takeOrderLabel.text = "--"
        }
        contentHeight += 40

        // 支付方式
        let payType = PayModel.PayType(rawValue: order.payWay ?? "unknown") ?? .unknown
        payTypeLabel.text = payType == .unknown ? "--" : payType.description
        contentHeight += 40

        var text = ""
        if status == .canceled {
            memoTagLabel.text = "取消原因："
            text = order.remark?.reason == "" ? "--" : (order.remark?.reason ?? "--")
        } else {
            memoTagLabel.text = "买家留言："
            text = order.remark?.remark == "" ? "--" : (order.remark?.remark ?? "--")
        }
        memoLabel.text = text
        let height = text.heightWith(font: memoLabel.font, limitWidth: UIScreen.width - 110)
        memoHeightConstraint.constant = height >= 80 ? 80 : height
        contentHeight += 110 + 50
        
        bottomView.isHidden = false
        deadServiceLabel.isHidden = true
        if let deadline = CityVModel.default.currentCity?.config?.orderDeadline {
            deadServiceLabel.text = "\(Date(timeIntervalSince1970: order.orderTime / 1000).format(to: "MM-dd "))\(deadline)前可取消"
        }
        bottomView0.isHidden = false
        bottomView1.isHidden = false
        bottomView1WidthConstraint.constant = 120
        contentHeight += 45
        switch status {
        case .unpaid:
            bottomView0.isHidden = false
            bottomButton1.setTitle("立即支付", for: .normal)
        case .paid:
            bottomView1.isHidden = true
            bottomView1WidthConstraint.constant = 0
        case .undeliver:
            deadServiceLabel.isHidden = false
            bottomView1.isHidden = true
            bottomView1WidthConstraint.constant = 0
        case .delivering:
            bottomView0.isHidden = true
            bottomButton1.setTitle("联系配送员", for: .normal)
        default:
            bottomView.isHidden = true
            contentHeight -= 45
        }

        contentHeightConstraint.constant = contentHeight
        scrollView.contentSize = CGSize(width: UIScreen.width, height: contentHeight)
    }
    
}

extension OrderDetailViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isExpanded ? products.count : min(products.count, 2)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(OrderProductTableViewCell.self)) as? OrderProductTableViewCell {
            cell.model = products[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
}

extension OrderDetailViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return OrderProductTableViewCell.height
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        GoodsDetailViewController.show(with: products[indexPath.row].productId)
    }

}
