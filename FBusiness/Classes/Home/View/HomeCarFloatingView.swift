//
//  HomeCarFloatingView.swift
//  FBusiness
//
//

import UIKit
import RxSwift
import RxCocoa
import SwiftX

public class HomeCarFloatingView: NSObject {
    
    public static let `default` = HomeCarFloatingView()

    private let badgeLabelHeight: CGFloat = 14

    private let contentHeight: CGFloat = 55
    
    private lazy var badgeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: contentHeight - badgeLabelHeight - 3, y: 3, width: badgeLabelHeight, height: badgeLabelHeight))
        
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 10)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor.red
        label.layer.cornerRadius = badgeLabelHeight / 2.0
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    private lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(x: UIScreen.width - contentHeight - 15, y: UIScreen.height - UIScreen.tabBarHeight - 15 - contentHeight, width: contentHeight, height: contentHeight))
        let imageView = UIImageView(frame: CGRect(x: 2, y: 2, width: contentHeight - 4, height: contentHeight - 4))
        imageView.image = UIImage(named: "icon_shop_car", in: Bundle.currentBase, compatibleWith: nil)
        imageView.layer.cornerRadius = (contentHeight - 4) / 2.0
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.7
        imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.addSubview(imageView)
        view.addSubview(badgeLabel)
        return view
    }()
    
    private override init() {
        super.init()
        
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        contentView.addGestureRecognizer(gesture)
        _ = gesture.rx.event
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { (_) in
                OrderSubmitViewController.show()
            })
        
        _ = CarVModel.default.datas.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (datas) in
                guard let weakSelf = self else { return }
                var count = 0
                for model in datas {
                    count += model.count
                }
                weakSelf.badgeLabel.isHidden = count == 0
                let size = "\(count)".boundingSize(with: CGSize(width: 100000, height: weakSelf.badgeLabelHeight), font: weakSelf.badgeLabel.font)
                let width = size.width > weakSelf.badgeLabelHeight ? size.width + 6 : weakSelf.badgeLabelHeight
                weakSelf.badgeLabel.text = "\(count)"
                weakSelf.badgeLabel.x = weakSelf.contentHeight - width
            })
    }

}

extension HomeCarFloatingView {
    
    public func _transform(view: UIView, fromScale: CGFloat, toScale: CGFloat, duration: TimeInterval) {
        view.transform = CGAffineTransform(scaleX: fromScale, y: fromScale)
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform(scaleX: toScale, y: toScale)
        }
    }
    
}

extension HomeCarFloatingView {
    
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
