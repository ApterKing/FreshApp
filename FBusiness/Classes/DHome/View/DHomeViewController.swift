//
//  DHomeViewController.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/25.
//

import UIKit
import SwiftX

public class DHomeViewController: BaseViewController {
    
    private var orderStatus: [OrderModel.Status] = [
        .delivering, .undeliver,
    ]
    private var segmentioView: BaseSegmentio!
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: CGRect(x: 0, y: BaseSegmentio.height, width: UIScreen.width, height: UIScreen.height - UIScreen.navigationBarHeight - BaseSegmentio.height))
        sv.delegate = self
        sv.showsHorizontalScrollIndicator = false
        sv.isPagingEnabled = true
        sv.bounces = false
        return sv
    }()
    private var childVCs: [DHomeSubViewController] = []
    private var initialIndex: Int = 0
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = true
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.height = view.height - segmentioView.height
        for (index, childVC) in childVCs.enumerated() {
            childVC.view.frame = CGRect(x: CGFloat(index) * UIScreen.width, y: 0, width: UIScreen.width, height: scrollView.height)
        }
    }
}

extension DHomeViewController {
    
    private func _initUI() {
        navigationItem.title = "鲜又多配送"

        navigationItem.rightBarButtonItem = rightBarButtonItem(image: UIImage(named: "icon_nav_history", in: Bundle.currentBase, compatibleWith: nil), size: CGSize(width: 30, height: 30)) { (_) in
            DHistoryViewController.show()
        }
        
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
            let childVC = DHomeSubViewController()
            childVC.status = orderStatus[index]
            addChild(childVC)
            scrollView.addSubview(childVC.view)
            childVC.view.frame = CGRect(x: CGFloat(index) * UIScreen.width, y: 0, width: UIScreen.width, height: scrollView.height)
            childVCs.append(childVC)
        }
        scrollView.contentSize = CGSize(width: UIScreen.width * CGFloat(orderStatus.count), height: scrollView.height)
        
        if initialIndex > orderStatus.count {
            initialIndex = 0
        }
        segmentioView.selectedIndex = initialIndex
        scrollView.contentOffset = CGPoint(x: CGFloat(initialIndex) * UIScreen.width, y: scrollView.height)
    }
    
}

extension DHomeViewController: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / UIScreen.width)
        segmentioView.selectedIndex = page
    }
    
}

