//
//  FloatingCarView.swift
//  FBusiness
//
//

import UIKit
import RxSwift
import RxCocoa
import SwiftX

public class FloatingCarView: NSObject {
    
    public static let `default` = FloatingCarView()
    
    private let badgeLabelHeight: CGFloat = 18
    private let contentHeight: CGFloat = 55
    
    private lazy var badgeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: contentHeight - badgeLabelHeight, y: 0, width: badgeLabelHeight, height: badgeLabelHeight))
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 8)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor(hexColor: "#FFA301")
        label.layer.cornerRadius = badgeLabelHeight / 2.0
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    private lazy var imageView: UIImageView = {
        let imgv = UIImageView(frame: CGRect(x: 2, y: 2, width: contentHeight - 4, height: contentHeight - 4))
        imgv.image = UIImage(named: "icon_shop_car", in: Bundle.currentBase, compatibleWith: nil)
        imgv.layer.cornerRadius = (contentHeight - 4) / 2.0
        imgv.layer.shadowColor = UIColor.gray.cgColor
        imgv.layer.shadowOpacity = 0.7
        imgv.layer.shadowOffset = CGSize(width: 0, height: 3)
        return imgv
    }()
    private lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(x: UIScreen.width - contentHeight - 15, y: UIScreen.height - UIScreen.tabBarHeight - 15 - contentHeight, width: contentHeight, height: contentHeight))
        view.addSubview(imageView)
        view.addSubview(badgeLabel)
        return view
    }()
    private var shouldShow: Bool {
        get {
            #if FRESH_CLIENT
            return (topViewController?.isKind(of: HomeViewController.self) ?? false || topViewController?.isKind(of: HomeMoreViewController.self) ?? false || topViewController?.isKind(of: GoodsDetailViewController.self) ?? false || topViewController?.isKind(of: SearchViewController.self) ?? false || topViewController?.isKind(of: CategorySubContainer.self) ?? false) && CarVModel.default.datas.value.count != 0
            #else
            return false
            #endif
        }
    }
    
    private override init() {
        super.init()
        
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        contentView.addGestureRecognizer(gesture)
        _ = gesture.rx.event
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { (_) in
//                if CarVModel.default.checkedCount() != 0 {
//                    if AddressVModel.default.currentAddress == nil {
//                        AddressListViewController.show(with: { (address) in
//                            AddressVModel.default.currentAddress = address
//                            OrderSubmitViewController.show()
//                        })
//                    } else {
//                        OrderSubmitViewController.show()
//                    }
//                } else if let tabbarVC = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
//                    topNavigationController?.popToRootViewController(animated: false)
//                    tabbarVC.selectedIndex = 2
//                }
                // 跳转购物车
                if let tabbarVC = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                    topNavigationController?.popToRootViewController(animated: false)
                    tabbarVC.selectedIndex = 2
                }
            })
        
        _ = CarVModel.default.datas.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (datas) in
                guard let weakSelf = self else { return }
                var count = 0
                for model in datas {
                    count += model.count
                }
                weakSelf.changeVisiable()
                let size = "\(count)".boundingSize(with: CGSize(width: 100000, height: weakSelf.badgeLabelHeight), font: weakSelf.badgeLabel.font)
                let width = size.width > weakSelf.badgeLabelHeight ? size.width + 6 : weakSelf.badgeLabelHeight
                weakSelf.badgeLabel.text = "\(count)"
                weakSelf.badgeLabel.x = weakSelf.contentHeight - width - 3
            })
    }
    
}

extension FloatingCarView {
    
    public func _transform(view: UIView, fromScale: CGFloat, toScale: CGFloat, duration: TimeInterval) {
        view.transform = CGAffineTransform(scaleX: fromScale, y: fromScale)
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform(scaleX: toScale, y: toScale)
        }
    }
    
}

extension FloatingCarView {
    
    public func changeVisiable() {
        if shouldShow {
            show()
        } else {
            dismiss()
        }
    }
    
    public func show(duration: TimeInterval = 0.25) {
        guard contentView.superview == nil else { return }
        UIApplication.shared.keyWindow?.addSubview(contentView)
        
        contentView.isHidden = false
        _transform(view: contentView, fromScale: 0.1, toScale: 0.3, duration: 0)
        UIView.animate(withDuration: duration, animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }) { (finish) in
            
        }
    }
    
    public func dismiss(duration: TimeInterval = 0.25) {
        guard contentView.superview != nil else { return }
        UIView.animate(withDuration: duration, animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (finish) in
            if finish {
                self.contentView.isHidden = true
                self.contentView.alpha = 1.0
            }
            self.contentView.removeFromSuperview()
        }
    }
    
}

