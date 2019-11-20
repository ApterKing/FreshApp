//
//  OrderSubTableViewCell.swift
//  FBusiness
//
//

import UIKit
import Toaster
import SwiftX

class OrderSubTableViewCell: UITableViewCell {
    
    @IBOutlet weak var SNOLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var deadServiceLabel: UILabel!
    @IBOutlet weak var funcButton: UIButton!
    @IBOutlet weak var funcTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var funcWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailButton: UIButton!
    
    private var orderVModel = OrderVModel()
    private let payWayView = OrderPayWayView.loadFromXib()

    var model: OrderDetailModel? {
        didSet {
            if let model = model, let order = model.order, let products = model.products {
                SNOLabel.text = order.orderSNo
                
                let status = OrderModel.Status(rawValue: order.orderStatus) ?? .unpaid
                statusLabel.text = status.description
                
                self.products = products
                var count = 0
                for product in products {
                    count += product.count ?? 0
                }
                count = max(products.count, count)
                countLabel.text = "共计 \(count) 件商品，合计："
                priceLabel.text = String(format: "￥%.2f", order.total)
                tableView.reloadData()
                
                deadServiceLabel.isHidden = true
                if let deadline = CityVModel.default.currentCity?.config?.orderDeadline {
                    deadServiceLabel.text = "\(Date(timeIntervalSince1970: order.orderTime / 1000).format(to: "MM-dd "))\(deadline)前可取消"
                }
                funcButton.isHidden = false
                funcTrailingConstraint.constant = 15
                funcWidthConstraint.constant = 71
                switch status {
                case .unpaid:
                    funcButton.setTitle("立即支付", for: .normal)
                case .paid:
                    funcButton.setTitle("取消订单", for: .normal)
                case .undeliver:
                    deadServiceLabel.isHidden = false
                    funcButton.setTitle("取消订单", for: .normal)
                case .delivering:
                    funcButton.setTitle("联系配送员", for: .normal)
                    funcTrailingConstraint.constant = 15
                    funcWidthConstraint.constant = 80
                case .finished, .canceled:
                    funcButton.isHidden = true
                    funcTrailingConstraint.constant = 0
                    funcWidthConstraint.constant = 0
                default:
                    break
                }
                
            }
        }
    }
    private var products = [ProductModel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tableView.register(UINib(nibName: "OrderProductTableViewCell", bundle: Bundle.currentCommon), forCellReuseIdentifier: NSStringFromClass(OrderProductTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
        Theme.decorate(button: detailButton, font: UIFont.systemFont(ofSize: 12), color: UIColor(hexColor: "#66B30C"), cornerRadius: 13)
        Theme.decorate(button: funcButton, font: UIFont.systemFont(ofSize: 12), color: UIColor(hexColor: "#ED9E32"), cornerRadius: 13)
        
        payWayView.dismiss()
        payWayView.handler = { [weak self] (type) in
            guard let weakSelf = self, let orderId = weakSelf.model?.order?.orderId else { return }
            topViewController?.startHUDAnimation()
            weakSelf.orderVModel.pay(orderId, type, { (payModel, error) in
                weakSelf.orderVModel.shouldShowToastWhen500Upper = true
                topViewController?.stopHUDAnimation()
                if let model = payModel {
                    PayVModel.default.pay(with: type, model: model, topNavigationController: nil)
                }
            })
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        guard let order = self.model?.order else { return }
        if sender.tag == 0 {
            OrderDetailViewController.show(order.orderId)
        } else {
            let status = OrderModel.Status(rawValue: order.orderStatus) ?? .unpaid
            switch status {
            case .unpaid:
                payWayView.show(with: order.orderMoney)
            case .paid, .undeliver:
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
                topViewController?.present(alertController, animated: true, completion: nil)
            case .delivering:
                guard let deliver = self.model?.delivery, let url = URL(string: "telprompt://\(deliver.userPhone ?? "")") else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            default:
                break
            }
        }
    }
    
}

extension OrderSubTableViewCell {
    
    private func _cancel() {
        guard let orderId = self.model?.order?.orderId else { return }
        topViewController?.startHUDAnimation()
        orderVModel.cancel(orderId) { [weak self] (baseModel, error) in
            topViewController?.stopHUDAnimation()
            self?.orderVModel.shouldShowToastWhen500Upper = true
            if error == nil {
                NotificationCenter.default.post(name: Constants.notification_order_canceled, object: nil)
            }
        }
    }
    
}

extension OrderSubTableViewCell {
    
    static public func calculateHeight(with orderDetail: OrderDetailModel) -> CGFloat {
        return OrderProductTableViewCell.height * CGFloat(orderDetail.products?.count ?? 0) + 130
    }
    
}

/// MARK: UITableView
extension OrderSubTableViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(OrderProductTableViewCell.self)) as? OrderProductTableViewCell {
            cell.separatorView.isHidden = indexPath.row == products.count - 1
            cell.model = products[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
}

extension OrderSubTableViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return OrderProductTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        GoodsDetailViewController.show(with: products[indexPath.row].productId)
    }
    
}
