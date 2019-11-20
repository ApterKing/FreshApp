//
//  CarTableViewHeaderView.swift
//  FBusiness
//
//

import UIKit
import RxSwift
import RxCocoa

class CarTableViewHeaderView: UIView {

    @IBOutlet weak var greenHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var view0HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var settlementButton: UIButton!
    @IBOutlet weak var view1AddAddressView: UIView!
    
    @IBOutlet weak var view1AddressView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var namePhoneLabel: UILabel!
    
    var addressModel: AddressModel? {
        didSet {
            if let model = addressModel {
                view1AddAddressView.isHidden = true
                view1AddressView.isHidden = false
                
                addressLabel.text = "\(model.area ?? "")\(model.userAddress ?? "")"
                namePhoneLabel.text = "\(model.userName)    \(model.userPhone)"
            } else {
                view1AddAddressView.isHidden = false
                view1AddressView.isHidden = true
            }
        }
    }
    
    var isSettlement: Bool = true {
        didSet {
            settlementButton.setTitle(isSettlement ? "管理" : "取消", for: .normal)
        }
    }
    
    class func loadFromXib() -> CarTableViewHeaderView {
        
        if let view = Bundle.currentCar.loadNibNamed("CarTableViewHeaderView", owner: self, options: nil)?.first as? CarTableViewHeaderView {
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: 225)
            return view
        }
        return CarTableViewHeaderView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        greenHeightConstraint.constant = UIScreen.navigationBarHeight + 55
        view0HeightConstraint.constant = UIScreen.navigationBarHeight
        
        view1AddAddressView.isHidden = false
        let addGesture = UITapGestureRecognizer(target: self, action: nil)
        view1AddAddressView.addGestureRecognizer(addGesture)
        _ = addGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (gesture) in
                AddressListViewController.show(with: { (model) in
                    AddressVModel.default.currentAddress = model
                    self?.addressModel = model
                })
            })
        
        view1AddressView.isHidden = true
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        view1AddressView.addGestureRecognizer(gesture)
        _ = gesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (gesture) in
                AddressListViewController.show(with: { (model) in
                    AddressVModel.default.currentAddress = model
                    self?.addressModel = model
                })
            })
        addressModel = AddressVModel.default.currentAddress
    }

}
