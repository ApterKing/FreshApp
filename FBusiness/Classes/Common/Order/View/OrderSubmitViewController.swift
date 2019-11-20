//
//  OrderSubmitViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster

class OrderSubmitViewController: BaseViewController {
    
    @IBOutlet weak var view0HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var namePhoneLabel: UILabel!
    
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var deliverMoneyLabel: UILabel!
    
    @IBOutlet weak var couponView: UIView!
    @IBOutlet weak var couponHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    private var selectedCouponIndexPath: IndexPath?
    
    @IBOutlet weak var memoView: UIView!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomOrgLabel: UILabel!
    @IBOutlet weak var bottomPriceLabel: UILabel!
    @IBOutlet weak var bottomContrainst: NSLayoutConstraint!
    
    private var dayFormat: String = Date().adding(.day, value: 1).format(to: "yyyy-MM-dd")
    private var timeModel: DeliveryTimeModel?
    private let timeChooseView = OrderTimeChooseView.loadFromXib()
    private let payWayView = OrderPayWayView.loadFromXib()
    private let memoInputView = OrderMemoInputView.loadFromXib()

    private let datas = CarVModel.default.checkedDatas()
    private var specialRow = -1  // 记录第一件特价商品的坐标
    
    private let couponVModel = CouponVModel()
    private let orderVModel = OrderVModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
        _loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
        
        if let model = AddressVModel.default.currentAddress {
            addressLabel.text = "\(model.area ?? "")\(model.userAddress ?? "")"
            namePhoneLabel.text = "\(model.userName)    \(model.userPhone)"
        }
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        if sender.tag == 0 {
            topNavigationController?.popViewController(animated: true)
        } else {
            // 提交订单
            guard timeModel != nil else {
                Toast.show("请先选择配送时间")
                return
            }
            payWayView.show(with: _calculatePriceAndResetUI().2)
        }
    }
    
}

extension OrderSubmitViewController {
    
    private func _initUI() {
        isNavigationBarHiddenIfNeeded = true

        view0HeightConstraint.constant = UIScreen.navigationBarHeight
        
        timeChooseView.dismiss()
        timeChooseView.handler = { [weak self] (dayFormat, model) in
            guard let weakSelf = self else { return }
            weakSelf.dayFormat = dayFormat
            weakSelf.timeModel = model
            
            let tomorrow = Date().format(to: "yyyy-MM-dd") == dayFormat
            weakSelf.timeLabel.text = "\(tomorrow ? "明天" : (Date.init(from: dayFormat, format: "yyyy-MM-dd")?.format(to: "MM月dd日"))!) \(model.deliverStartTime)-\(model.deliverEndTime)"
            weakSelf.timeLabel.textColor = UIColor(hexColor: "#66B30C")
            _ = weakSelf._calculatePriceAndResetUI()
        }
        
        memoInputView.dismiss()
        memoInputView.handler = { [weak self] (text) in
            guard let weakSelf = self, text != "" else { return }
            weakSelf.memoLabel.text = text
            let height = text.heightWith(font: weakSelf.memoLabel.font, limitWidth: UIScreen.width - 30)
            weakSelf.memoLabelHeightConstraint.constant = height > 80 ? 80 : height
        }
        
        payWayView.dismiss()
        payWayView.handler = { [weak self] (type) in
            self?._addOrder(type)
        }

        // 地址
        let addressGesture = UITapGestureRecognizer(target: self, action: nil)
        addressView.addGestureRecognizer(addressGesture)
        _ = addressGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { (_) in
                AddressListViewController.show(with: { (model) in
                    AddressVModel.default.currentAddress = model
                })
            })

        let timeGesture = UITapGestureRecognizer(target: self, action: nil)
        timeView.addGestureRecognizer(timeGesture)
        _ = timeGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.timeChooseView.show()
            })
        
        
        tableView.register(UINib(nibName: "OrderSubmitTableViewCell", bundle: Bundle.currentCommon), forCellReuseIdentifier: NSStringFromClass(OrderSubmitTableViewCell.self))
        tableHeightConstraint.constant = CGFloat(datas.count) * OrderSubmitTableViewCell.height
        
        countLabel.text = "共\(CarVModel.default.checkedCount())件"

        collectionView.register(UINib(nibName: "OrderSubmitCouponCollectionViewCell", bundle: Bundle.currentCommon), forCellWithReuseIdentifier: NSStringFromClass(OrderSubmitCouponCollectionViewCell.self))
        
        couponHeightConstraint.constant = 0
        let height = 245 + CGFloat(datas.count) * OrderSubmitTableViewCell.height
        contentHeightConstraint.constant = height
        scrollView.contentSize = CGSize(width: UIScreen.width, height: height)
        
        let memoGesture = UITapGestureRecognizer(target: self, action: nil)
        memoView.addGestureRecognizer(memoGesture)
        _ = memoGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                let isEqualInitailizer = self?.memoLabel.text == "选填备注信息"
                self?.memoInputView.show(with: isEqualInitailizer ? nil : self?.memoLabel.text)
            })

        bottomContrainst.constant = UIScreen.homeIndicatorMoreHeight
        
        _ = _calculatePriceAndResetUI()
        
        // 数据显示的逆序找出第一件特价商品坐标
        for (index, model) in datas.reversed().enumerated() {
            print("fuck########     \(String(describing: model.productType))")
            if (model.productType ?? "normal") == ProductModel.ProductType.specialPrice.rawValue  {
                specialRow = datas.count - index - 1
                print("fuck########     \(String(describing: model.productType))    \(specialRow)")
                break
            }
        }
        print("fuck########   \(specialRow)")
    }
    
    private func _loadData() {
        couponVModel.fetch { [weak self] (error) in
            guard let weakSelf = self, error == nil else { return }
            weakSelf.couponHeightConstraint.constant = 140
            weakSelf.couponView.isHidden = false
            let height = 245 + 140 + CGFloat(weakSelf.datas.count) * OrderSubmitTableViewCell.height
            weakSelf.contentHeightConstraint.constant = height
            weakSelf.scrollView.contentSize = CGSize(width: UIScreen.width, height: height)
            weakSelf.collectionView.reloadData()
            
            weakSelf.collectionView.isHidden = weakSelf.couponVModel.datas.count == 0
        }
    }
    
    private func _addOrder(_ payType: PayModel.PayType) {
        guard let productData = try? JSONEncoder.encode(CarVModel.default.checkedDatas().reversed()), let productString = String(data: productData, encoding: .utf8), let timeModel = timeModel else { return }
        let result = _calculatePriceAndResetUI()
        var params: [AnyHashable: Any] = [
            "products": productString,
            "addressId": AddressVModel.default.currentAddress?.addressId ?? "",
            "deliverMoney": result.0,
            "deliverStartDate": Int(Date(from: "\(dayFormat) \(timeModel.deliverStartTime):00", format: "yyyy-MM-dd HH:mm:ss")?.timestamp ?? Date().timestamp) * 1000,
            "deliverEndDate": Int(Date(from: "\(dayFormat) \(timeModel.deliverEndTime):00", format: "yyyy-MM-dd HH:mm:ss")?.timestamp ?? Date().timestamp) * 1000,
            "payWay": payType.rawValue,
            "orderOrgMoney": result.1,
            "orderMoney": result.2,
            "cityId": CityVModel.default.currentCity?.cityId ?? "",
            "remark": memoLabel.text == "选填备注信息" ? "" : (memoLabel.text ?? ""),
        ]
        if let selectedIndex = selectedCouponIndexPath?.row, selectedIndex < couponVModel.datas.count {
            let coupon = couponVModel.datas[selectedIndex]
            params["couponId"] = coupon.couponId
        }
        startHUDAnimation()
        orderVModel.add(params, payType) { [weak self] (payModel, error) in
            guard let weakSelf = self else { return }
            weakSelf.stopHUDAnimation()
            if let model = payModel {
                // 本地删除已生成的订单的商品
                var datas = CarVModel.default.datas.value
                let deleteDataIds = CarVModel.default.checkedDatas().map({ (model) -> String in
                    return model.cartId
                })
                datas.removeAll(where: { (model) -> Bool in
                    return deleteDataIds.contains(model.cartId)
                })
                CarVModel.default.datas.accept(datas)

                // 订单创建成功后需要刷新购物车列表
                CarVModel.default.fetch(nil)
                PayVModel.default.pay(with: payType, model: model, topNavigationController: topNavigationController)
            }
        }
    }
    
    // 计算总价，并且设置对应的UI显示 return (deliveryMoney, orgPrice, price)
    private func _calculatePriceAndResetUI() -> (Float, Float, Float) {
        var deliveryMoney: Float = 0
        
        // 得到商品价格
        var orgPrice = CarVModel.default.checkedOrgPrice()
        var price = CarVModel.default.checkedPrice()
        
        // 先计算优惠券折后价
        if let selectedIndex = selectedCouponIndexPath?.row, selectedIndex < couponVModel.datas.count {
            let coupon = couponVModel.datas[selectedIndex]
            if coupon.couponType == CouponModel.CouponType.discount.rawValue {  // 折扣券
                discountLabel.text = String(format: "-￥%.2f", price * (1 - (coupon.couponConfig?.discount ?? 1)))
                price = price * (coupon.couponConfig?.discount ?? 1)
                orgPrice += price * (1 - (coupon.couponConfig?.discount ?? 1))
            } else {
                discountLabel.text = String(format: "-￥%.2f", -(coupon.couponConfig?.reduce ?? 0))
                price += coupon.couponConfig?.reduce ?? 0
                orgPrice += coupon.couponConfig?.reduce ?? 0
            }
        } else {
            discountLabel.text = ""
        }
        
        // 再计算配送费 （配送费的计费价格是优惠后的价格）
        if let model = timeModel {
            if price >= 0 && price < (model.deliverFreeOrderMoney ?? 0) {
                price += model.deliveryMoney
                orgPrice += model.deliveryMoney
                deliverMoneyLabel.text = String(format: "￥%.2f", model.deliveryMoney)
                deliveryMoney = model.deliveryMoney
            } else {
                deliverMoneyLabel.text = "免配送费"
            }
        } else {
            deliverMoneyLabel.text = ""
        }
        
        let priceText = String(format: "￥%.2f", orgPrice < 0 ? 0 : orgPrice)
        let attributedString = NSMutableAttributedString(string: priceText, attributes: [NSAttributedString.Key.strikethroughStyle: 1])
        bottomOrgLabel.attributedText = attributedString
        
        price = price < 0 ? 0 : price
        bottomPriceLabel.text = String(format: "￥ %.2f", price)
        
        return (deliveryMoney, CarVModel.default.checkedPrice(), price)
    }
}

extension OrderSubmitViewController {
    
    static public func show() {
        let vc = OrderSubmitViewController(nibName: "OrderSubmitViewController", bundle: Bundle.currentCommon)
        vc.hidesBottomBarWhenPushed = true
        topNavigationController?.pushViewController(vc, animated: true)
    }

}

/// MARK: UITableView
extension OrderSubmitViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(OrderSubmitTableViewCell.self)) as? OrderSubmitTableViewCell {
            let data = datas[indexPath.row]
            var hasSpecial = true  // 默认所有商品都是已经显示过特价
            if indexPath.row == specialRow && data.productType == ProductModel.ProductType.specialPrice.rawValue {
                hasSpecial = false  // 当为第一个特价的时候，设置为没有显示过特价
            }
            cell.setData(datas[indexPath.row], hasSpecial)
            return cell
        }
        return UITableViewCell()
    }

}

extension OrderSubmitViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return OrderSubmitTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        GoodsDetailViewController.show(with: datas[indexPath.row].productId)
    }
    
}

/// MARK: UICollectionView
extension OrderSubmitViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return couponVModel.datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(OrderSubmitCouponCollectionViewCell.self), for: indexPath) as? OrderSubmitCouponCollectionViewCell {
            cell.model = couponVModel.datas[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
}

extension OrderSubmitViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedCouponIndexPath?.row == indexPath.row {
            collectionView.deselectItem(at: indexPath, animated: true)
            selectedCouponIndexPath = nil
            _ = _calculatePriceAndResetUI()
        } else {
            // 判定是否满足可以减免
            let coupon = couponVModel.datas[indexPath.row]
            let minConsum = coupon.couponConfig?.minConsum ?? 0
            guard CarVModel.default.checkedPrice() >= minConsum else {
                Toast.show("该笔订单不满足使用条件")
                return
            }
            selectedCouponIndexPath = indexPath
            _ = _calculatePriceAndResetUI()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return OrderSubmitCouponCollectionViewCell.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
}
