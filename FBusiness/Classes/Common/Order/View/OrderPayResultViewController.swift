//
//  OrderPayResultViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX

public class OrderPayResultViewController: BaseViewController {
    public enum Result {
        case success()
        case failure(_ reason: String)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var checkHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backToHomeButton: UIButton!
    
    private var result: Result = .success()
    private var isOrder = true

    override public func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] () in
            if sender.tag == 0 {
                if self?.isOrder ?? true {
                    OrderSubContainer.show(with: .undeliver)
                } else {
                    HouseKeepingContainer.show(with: .paid)
                }
            } else {
                topNavigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
}

extension OrderPayResultViewController {
    
    private func _initUI() {
        navigationItem.title = "支付结果"
        navigationItemBackStyle = .closeGray
        switch result {
        case .success():
            imageView.image = UIImage(named: "icon_order_completed_empty", in: Bundle.currentBase, compatibleWith: nil)
            promptLabel.text = "恭喜，下单成功"
            checkButton.isHidden = false
            checkHeightConstraint.constant = 45
            checkTopConstraint.constant = 40
        case .failure(let reason):
            imageView.image = UIImage(named: "icon_order_canceled_empty", in: Bundle.currentBase, compatibleWith: nil)
            promptLabel.text = reason
            checkButton.isHidden = true
            checkHeightConstraint.constant = 0
            checkTopConstraint.constant = 20
        }

        Theme.decorate(button: checkButton)
        backToHomeButton.setTitleColor(UIColor(hexColor: "#66B30C"), for: .normal)
        backToHomeButton.backgroundColor = UIColor.clear
        backToHomeButton.layer.cornerRadius = 5
        backToHomeButton.layer.borderColor = UIColor(hexColor: "#66B30C").cgColor
        backToHomeButton.layer.borderWidth = 1.5
        backToHomeButton.clipsToBounds = true
    }

}

extension OrderPayResultViewController {
    
    // isOrder == true 则是订单，否则为家政服务，如果navigationController 不为空，意味着需要关闭前一个页面
    static public func show(with result: Result, isOrder: Bool = true, navigationController: UINavigationController? = nil) {
        let vc = OrderPayResultViewController(nibName: "OrderPayResultViewController", bundle: Bundle.currentCommon)
        vc.result = result
        vc.isOrder = isOrder
        vc.hidesBottomBarWhenPushed = true
        topViewController?.present(XBaseNavigationController(rootViewController: vc), animated: true, completion: {
            navigationController?.popViewController(animated: false)
        })
    }
    
}
