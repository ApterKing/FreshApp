//
//  AddressAddViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import RxSwift
import RxCocoa
import Toaster

class AddressAddViewController: BaseViewController {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var sirView: UIView!
    @IBOutlet weak var sirImageView: UIImageView!
    
    @IBOutlet weak var ladyView: UIView!
    @IBOutlet weak var ladyImageView: UIImageView!
    
    @IBOutlet var phoneField: UITextField!
    
    @IBOutlet var addressField: UITextField!
    @IBOutlet var addressDetailField: UITextField!
    
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet weak var defaultImageView: UIImageView!
    
    @IBOutlet weak var defaultNoView: UIView!
    @IBOutlet weak var defaultNoImageView: UIImageView!
    
    @IBOutlet var saveButton: UIButton!
    
    
    private var sexual: BehaviorRelay<String> = BehaviorRelay<String>(value: UserModel.Sexual.male.rawValue)
    private var isDefault: BehaviorRelay<String> = BehaviorRelay<String>(value: "yes")
    private var location: CLLocationCoordinate2D?
    
    private var addressModel: AddressModel? {
        didSet {
            if let latitudeString = addressModel?.latitude, let longitudeString = addressModel?.longitude, let latitude = Double(latitudeString), let longitude = Double(longitudeString)  {
                location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }
    }
    private let vmmodel = AddressVModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardObserver()
        
        _initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        save()
    }
}

extension AddressAddViewController {
    
    private func _initUI() {
        isNavigationBarShadowImageHidden = false
        navigationItem.title = addressModel == nil ? "新增地址" : "编辑地址"
        
        let sirGesture = UITapGestureRecognizer(target: self, action: nil)
        sirView.addGestureRecognizer(sirGesture)
        _ = sirGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.view.endEditing(true)
                self?.sexual.accept(UserModel.Sexual.male.rawValue)
            })
        
        let ladyGesture = UITapGestureRecognizer(target: self, action: nil)
        ladyView.addGestureRecognizer(ladyGesture)
        _ = ladyGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.view.endEditing(true)
                self?.sexual.accept(UserModel.Sexual.female.rawValue)
            })
        
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
                XLocationSelectionViewController.show(coordinate: self?.location, poiSearchCity: CityVModel.default.currentCity?.cityName, with: { (info) in
                    if let info = info {
                        self?.location = info.location
                        self?.addressField.text = info.address
                    }
                })
            })
        
        let defaultGesture = UITapGestureRecognizer(target: self, action: nil)
        defaultView.addGestureRecognizer(defaultGesture)
        _ = defaultGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.view.endEditing(true)
                self?.isDefault.accept("yes")
            })
        
        let defaultNoGesture = UITapGestureRecognizer(target: self, action: nil)
        defaultNoView.addGestureRecognizer(defaultNoGesture)
        _ = defaultNoGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.view.endEditing(true)
                self?.isDefault.accept("no")
            })
        
        Theme.decorate(button: saveButton)
        
        if let model = addressModel {
            nameField.text = model.userName
            sexual.accept(model.sexual ?? UserModel.Sexual.male.rawValue)
            phoneField.text = model.userPhone
            addressField.text = model.area
            addressDetailField.text = model.userAddress
            isDefault.accept(model.isDefault ?? "yes")
            saveButton.isEnabled = true
        }
        
        _ = sexual.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (sex) in
                if sex == UserModel.Sexual.male.rawValue {
                    self?.sirImageView.image = UIImage(named: "icon_checked", in: Bundle.currentBase, compatibleWith: nil)
                    self?.ladyImageView.image = UIImage(named: "icon_uncheck", in: Bundle.currentBase, compatibleWith: nil)
                } else {
                    self?.sirImageView.image = UIImage(named: "icon_uncheck", in: Bundle.currentBase, compatibleWith: nil)
                    self?.ladyImageView.image = UIImage(named: "icon_checked", in: Bundle.currentBase, compatibleWith: nil)
                }
            })
        
        _ = isDefault.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (isDefault) in
                if isDefault == "yes" {
                    self?.defaultImageView.image = UIImage(named: "icon_checked", in: Bundle.currentBase, compatibleWith: nil)
                    self?.defaultNoImageView.image = UIImage(named: "icon_uncheck", in: Bundle.currentBase, compatibleWith: nil)
                } else {
                    self?.defaultImageView.image = UIImage(named: "icon_uncheck", in: Bundle.currentBase, compatibleWith: nil)
                    self?.defaultNoImageView.image = UIImage(named: "icon_checked", in: Bundle.currentBase, compatibleWith: nil)
                }
            })
        
        _ = NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                self?._keyboardWillChangeFrame(notification)
            })
    }
    
    private func save() {
        let model = AddressModel()
        model.addressId = addressModel?.addressId
        guard let name = nameField.text else {
            Toast.show("请填写收货人")
            return
        }
        model.userName = name
        guard let phone = phoneField.text, phone.count == 11 else {
            Toast.show("请填写正确的电话号码")
            return
        }
        model.userPhone = phone
        guard let address = addressField.text else {
            Toast.show("请选择收货地址")
            return
        }
        model.area = address
        if let location = self.location {
            model.latitude = "\(location.latitude)"
            model.longitude = "\(location.longitude)"
        }
        guard let addressDetail = addressDetailField.text else {
            Toast.show("请填写详细地址/门牌号")
            return
        }
        model.address = addressDetail
        model.sexual = sexual.value
        model.isDefault = isDefault.value
        startHUDAnimation()
        vmmodel.add(model) { (baseModel, error) in
            if let base = baseModel {
                model.addressId = base.msg
                NotificationCenter.default.post(name: AddressVModel.AddressChangeNotification, object: nil)
                topNavigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func _keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let endY = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.origin.y ?? 0
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
        
        var targetTop: CGFloat = 15
        if endY != UIScreen.height && addressDetailField.isFirstResponder {
            targetTop = UIDevice.isIphone4_5() ? -15 : 0
        }
        topConstraint.constant = targetTop
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
}

extension AddressAddViewController {
    
    static public func show(_ model: AddressModel? = nil) {
        UserVModel.default.verify { (success) in
            if success {
                let vc = AddressAddViewController(nibName: "AddressAddViewController", bundle: Bundle.currentCommon)
                vc.addressModel = model
                vc.hidesBottomBarWhenPushed = true
                topNavigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

extension AddressAddViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard textField != addressField else { return false }
        if textField == phoneField {
            textField.keyboardType = .numberPad
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var targetStr = NSString(string: textField.attributedText?.string ?? "").replacingCharacters(in: range, with: string)
        
        if textField == phoneField {
            let text = targetStr.trimmingCharacters(in: CharacterSet.whitespaces)
            if text.count > 11 {
                let targetIndex = targetStr.index(targetStr.startIndex, offsetBy: 11)
                targetStr = String(targetStr.prefix(upTo: targetIndex))
                textField.text = targetStr
                return false
            }
            return true
        } else if textField == addressDetailField || textField == nameField {
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            if textField.text != "" {
                phoneField.becomeFirstResponder()
            }
        } else if textField == phoneField {
            if phoneField.text != "" {
                addressDetailField.becomeFirstResponder()
            }
        } else if textField == addressDetailField  {
            if textField.text != "" {
                textField.resignFirstResponder()
            }
        }
        return false
    }
}

