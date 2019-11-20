//
//  OrderSubContainer.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class OrderSubContainer: BaseViewController {
    
    private var orderStatus: [OrderModel.Status] = [
        .unpaid, .undeliver, .delivering, .finished, .canceled
    ]
    private var segmentioView: BaseSegmentio!
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: CGRect(x: 0, y: BaseSegmentio.height, width: UIScreen.width, height: UIScreen.height - UIScreen.navigationBarHeight - BaseSegmentio.height - UIScreen.homeIndicatorMoreHeight))
        sv.showsHorizontalScrollIndicator = false
        sv.delegate = self
        sv.isPagingEnabled = true
        sv.bounces = false
        return sv
    }()
    private var childVCs: [OrderSubViewController] = []
    private var initialIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.height = view.height - segmentioView.height - UIScreen.homeIndicatorMoreHeight
        for (index, childVC) in childVCs.enumerated() {
            childVC.view.frame = CGRect(x: CGFloat(index) * UIScreen.width, y: 0, width: UIScreen.width, height: scrollView.height)
        }
    }
}

extension OrderSubContainer {
    
    private func _initUI() {
        navigationItem.title = "我的订单"

        segmentioView = BaseSegmentio(orderStatus.map({ (status) -> String in
            return status.description
        }), .dynamic, 0.2, true)
        segmentioView.valueDidChange = { [weak self] (segmentio, segmentioIndex) in
            guard let weakSelf = self else { return }
            weakSelf.scrollView.setContentOffset(CGPoint(x: CGFloat(segmentioIndex) * UIScreen.width, y: 0), animated: true)
        }
        view.addSubview(segmentioView)
        
        view.addSubview(scrollView)
        for index in 0..<orderStatus.count {
            let childVC = OrderSubViewController()
            childVC.status = orderStatus[index]
            addChild(childVC)
            scrollView.addSubview(childVC.view)
            childVC.view.frame = CGRect(x: CGFloat(index) * UIScreen.width, y: 0, width: UIScreen.width, height: scrollView.height)
            childVCs.append(childVC)
        }
        scrollView.contentSize = CGSize(width: UIScreen.width * CGFloat(orderStatus.count), height: 0)
        
        if initialIndex > orderStatus.count {
            initialIndex = 0
        }
        segmentioView.selectedIndex = initialIndex
        scrollView.contentOffset = CGPoint(x: CGFloat(initialIndex) * UIScreen.width, y: 0)
    }
    
    @objc private func _gotoSearchViewController() {
        SearchViewController.show()
    }
    
}

extension OrderSubContainer {
    
    static func show(with status: OrderModel.Status = .unpaid) {
        UserVModel.default.verify({ (success) in
            let vc = OrderSubContainer()
            for (index, tmpStatus) in vc.orderStatus.enumerated() {
                if status == tmpStatus {
                    vc.initialIndex = index
                    break
                }
            }
            vc.hidesBottomBarWhenPushed = true
            topNavigationController?.pushViewController(vc, animated: true)
        })
    }
}

extension OrderSubContainer: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / UIScreen.width)
        segmentioView.selectedIndex = page
    }
    
}

