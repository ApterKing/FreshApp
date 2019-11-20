//
//  HouserKeepingAddViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import RxSwift
import RxCocoa
import Toaster

public class HouserKeepingAddViewController: BaseViewController {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var addressDetailField: UITextField!
    @IBOutlet weak var areaField: UITextField!
    @IBOutlet weak var feeField: UITextField!
    @IBOutlet weak var timeField: UITextField!

    @IBOutlet weak var memoView: UIView!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var subscribeButton: UIButton!
    
    private let payWayView = OrderPayWayView.loadFromXib()
    private let memoInputView = OrderMemoInputView.loadFromXib()
    
    private let pickerView = HousePickerView.loadFromXib()
    private var selectedDate: Date?

    private var addressModel: AddressModel? {
        didSet {
            if let model = addressModel {
                addressField.text = model.area
                addressDetailField.text = model.userAddress
            }
        }
    }
    private var vmodel = HouseKeepingVModel()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardObserver()

        _initUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        UserVModel.default.verify { [weak self] (success) in
            guard let weakSelf = self else { return }
            guard (weakSelf.addressModel?.addressId) != nil else {
                Toast.show("请选择您的地址")
                return
            }
            guard weakSelf.areaField.text != nil else {
                Toast.show("请填写房屋总面积")
                return
            }
            guard weakSelf.timeField.text != nil else {
                Toast.show("请选择服务时间")
                return
            }
            if let weakSelf = self, success {
                self?.payWayView.show(with: (Float(weakSelf.areaField.text ?? "0") ?? 0) * (CityVModel.default.currentCity?.config?.homeServiceFee ?? 12))
            }
        }
    }
    
}

extension HouserKeepingAddViewController {
    
    private func _initUI() {
        navigationItem.title = "预约服务"

        contentHeightConstraint.constant = 640
        scrollView.contentSize = CGSize(width: UIScreen.width, height: 640)

        let leftImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 12))
        leftImageView.image = UIImage(named: "icon_location_gray", in: Bundle.currentBase, compatibleWith: nil)
        leftImageView.contentMode = .scaleAspectFit
        addressField.leftView = leftImageView
        addressField.leftViewMode = .always
        let addressGesture = UITapGestureRecognizer(target: self, action: nil)
        addressField.addGestureRecognizer(addressGesture)
        _ = addressGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.view.endEditing(true)
                AddressListViewController.show(with: { (model) in
                    self?.addressModel = model
                })
            })
        let addressDetailGesture = UITapGestureRecognizer(target: self, action: nil)
        addressDetailField.addGestureRecognizer(addressDetailGesture)
        _ = addressDetailGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.view.endEditing(true)
                AddressListViewController.show(with: { (model) in
                    self?.addressModel = model
                })
            })
        
        _ = NotificationCenter.default.rx.notification(UITextField.textDidChangeNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                if (self?.areaField.text ?? "") == "" {
                    self?.feeField.text = nil
                } else {
                    self?.feeField.text = String(format: "总价：￥%.2f", (Float(self?.areaField.text ?? "0") ?? 0) * (CityVModel.default.currentCity?.config?.homeServiceFee ?? 12))
                }
            })
        
        feeField.placeholder = String(format: "保洁服务单价：%.2f/平米", CityVModel.default.currentCity?.config?.homeServiceFee ?? 12.0)
        
        let timeGesture = UITapGestureRecognizer(target: self, action: nil)
        timeField.addGestureRecognizer(timeGesture)
        _ = timeGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.view.endEditing(true)
                self?.pickerView.show(with: self?.selectedDate ?? Date())
            })
       
        let memoGesture = UITapGestureRecognizer(target: self, action: nil)
        memoView.addGestureRecognizer(memoGesture)
        _ = memoGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                let isEqualInitailizer = self?.memoLabel.text == "选填预约备注信息"
                self?.memoInputView.show(with: isEqualInitailizer ? nil : self?.memoLabel.text)
            })
        
        
        Theme.decorate(button: subscribeButton)
        
        pickerView.dismiss()
        pickerView.handler = { [weak self] (value) in
            guard let weakSelf = self else { return }
            weakSelf.selectedDate = value
            weakSelf.timeField.text = value.format(to: "yyyy-MM-dd HH:mm")
        }
        
        memoInputView.dismiss()
        memoInputView.handler = { [weak self] (text) in
            guard let weakSelf = self, text != "" else { return }
            weakSelf.memoLabel.text = text
            let height = text.heightWith(font: weakSelf.memoLabel.font, limitWidth: UIScreen.width - 30)
            weakSelf.memoLabelHeightConstraint.constant = height > 85 ? 85 : height
        }
        
        payWayView.dismiss()
        payWayView.enableTrustAccount = false
        payWayView.handler = { [weak self] (type) in
            self?._subscribe(type)
        }
    }
    
    private func _subscribe(_ type: PayModel.PayType = .wxpay) {
        guard let addressId = addressModel?.addressId else {
            Toast.show("请选择您的地址")
            return
        }
        guard let area = areaField.text else {
            Toast.show("请填写房屋总面积")
            return
        }
        guard timeField.text != nil else {
            Toast.show("请选择服务时间")
            return
        }
        var params: [AnyHashable: Any] = [
            "addressId": addressId,
            "houseArea": area,
            "cityId": CityVModel.default.currentCityCode,
            "payWay": type.rawValue
        ]
        let date = selectedDate ?? Date().adding(Calendar.Component.day, value: 1)
        params["serviceTime"] = Int(date.timestamp) * 1000
        if memoLabel.text != "选填预约备注信息" {
            params["remark"] = memoLabel.text ?? ""
        }
        startHUDAnimation()
        vmodel.add(params, type) { [weak self] (model, error) in
            self?.stopHUDAnimation()
            if let model = model {
                PayVModel.default.pay(with: type, model: model, isOrder: false, topNavigationController: topNavigationController, completion: nil)
            }
        }
    }
    
}

extension HouserKeepingAddViewController {
    
    static public func show(_ model: AddressModel? = nil) {
        let vc = HouserKeepingAddViewController(nibName: "HouserKeepingAddViewController", bundle: Bundle.currentCommon)
        vc.hidesBottomBarWhenPushed = true
        topNavigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HouserKeepingAddViewController: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == areaField {
            textField.keyboardType = .numberPad
        }
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
}
