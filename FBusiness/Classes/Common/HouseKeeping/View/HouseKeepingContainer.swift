//
//  HouseKeepingContainer.swift
//  FBusiness
//
//

import UIKit
import SwiftX

public class HouseKeepingContainer: BaseViewController {
    
    private var houseStatus: [HouseKeepingModel.Status] = [
        .unpaid, .paid, .recived, .finished, .canceled
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
    private var childVCs: [HouseKeepingSubViewController] = []
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
        scrollView.height = view.height - segmentioView.height - UIScreen.homeIndicatorMoreHeight
        for (index, childVC) in childVCs.enumerated() {
            childVC.view.frame = CGRect(x: CGFloat(index) * UIScreen.width, y: 0, width: UIScreen.width, height: scrollView.height)
        }
    }
}

extension HouseKeepingContainer {
    
    private func _initUI() {
        navigationItem.title = "家政服务"
        
        segmentioView = BaseSegmentio(houseStatus.map({ (status) -> String in
            return status.description
        }), .dynamic, 0.2, true)
        segmentioView.valueDidChange = { [weak self] (segmentio, segmentioIndex) in
            guard let weakSelf = self else { return }
            weakSelf.scrollView.setContentOffset(CGPoint(x: CGFloat(segmentioIndex) * UIScreen.width, y: 0), animated: true)
        }
        view.addSubview(segmentioView)
        
        view.addSubview(scrollView)
        for index in 0..<houseStatus.count {
            let childVC = HouseKeepingSubViewController()
            childVC.status = houseStatus[index]
            addChild(childVC)
            scrollView.addSubview(childVC.view)
            childVC.view.frame = CGRect(x: CGFloat(index) * UIScreen.width, y: 0, width: UIScreen.width, height: scrollView.height)
            childVCs.append(childVC)
        }
        scrollView.contentSize = CGSize(width: UIScreen.width * CGFloat(houseStatus.count), height: 0)
        
        if initialIndex > houseStatus.count {
            initialIndex = 0
        }
        segmentioView.selectedIndex = initialIndex
        scrollView.contentOffset = CGPoint(x: CGFloat(initialIndex) * UIScreen.width, y: 0)
    }
    
    @objc private func _gotoSearchViewController() {
        SearchViewController.show()
    }
    
}

extension HouseKeepingContainer {
    
    static func show(with status: HouseKeepingModel.Status = .unpaid) {
        UserVModel.default.verify({ (success) in
            if success {
                guard topViewController?.isKind(of: HouseKeepingContainer.self) == false else { return }
                let vc = HouseKeepingContainer()
                for (index, tmpStatus) in vc.houseStatus.enumerated() {
                    if status == tmpStatus {
                        vc.initialIndex = index
                        break
                    }
                }
                vc.hidesBottomBarWhenPushed = true
                topNavigationController?.pushViewController(vc, animated: true)
            }
        })
    }
}

extension HouseKeepingContainer: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / UIScreen.width)
        segmentioView.selectedIndex = page
    }
    
}

