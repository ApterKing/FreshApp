//
//  CategorySubContainer.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class CategorySubContainer: BaseViewController {
    
    private var segmentioView: BaseSegmentio!
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: CGRect(x: 0, y: BaseSegmentio.height, width: UIScreen.width, height: UIScreen.height - UIScreen.navigationBarHeight - UIScreen.homeIndicatorMoreHeight - BaseSegmentio.height))
        sv.showsHorizontalScrollIndicator = false
        sv.delegate = self
        sv.isPagingEnabled = true
        sv.bounces = false
        return sv
    }()
    private var childVCs: [CategorySubViewController] = []
    private var categoriesWithAll: [CategoryModel] = []
    private var initialIndex: Int = 0
    private var pcatelogId: String?    // 一级分类id

    override func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
    }
    
}

extension CategorySubContainer {

    /// index: 显示第几个，categories：子subs，pcatelogId： 一级分类id
    static public func show(_ index: Int, _ categories: [CategoryModel], _ pcatelogId: String) {
        let vc = CategorySubContainer()
        vc.pcatelogId = pcatelogId

        // 构造一个全部
        let category = CategoryModel()
        category.catelogId = pcatelogId
        category.catelogName = "全部"
        vc.categoriesWithAll.removeAll()
        vc.categoriesWithAll.append(category)
        vc.categoriesWithAll.append(contentsOf: categories)
        vc.initialIndex = index > vc.categoriesWithAll.count - 1 ? vc.categoriesWithAll.count - 1 : index
        vc.hidesBottomBarWhenPushed =  true
        topNavigationController?.pushViewController(vc, animated: true)
    }
    
}

extension CategorySubContainer {
    
    private func _initUI() {
        let searchBar = XSearchBar(frame: CGRect(x: 30, y: 2, width: UIScreen.width - 70, height: 40))
        searchBar.editable = false
        searchBar.placeholder = "输入搜索的商品名称"
        navigationItem.titleView = searchBar
        let gesture = UITapGestureRecognizer(target: self, action: #selector(_gotoSearchViewController))
        searchBar.addGestureRecognizer(gesture)
        
        let titles = categoriesWithAll.map({ (model) -> String in
            return model.catelogName
        })
        segmentioView = BaseSegmentio(titles, .dynamic, 0.2, true)
        segmentioView.selectedIndex = initialIndex
        segmentioView.valueDidChange = { [weak self] (segmentio, segmentioIndex) in
            guard let weakSelf = self else { return }
            weakSelf.scrollView.setContentOffset(CGPoint(x: CGFloat(segmentioIndex) * UIScreen.width, y: 0), animated: true)
        }
        view.addSubview(segmentioView)

        scrollView.frame = CGRect(x: 0, y: categoriesWithAll.count <= 1 ? 0 : BaseSegmentio.height, width: UIScreen.width, height: UIScreen.height - UIScreen.navigationBarHeight - UIScreen.homeIndicatorMoreHeight - (categoriesWithAll.count <= 1 ? 0 : BaseSegmentio.height))
        view.addSubview(scrollView)
        for index in 0..<categoriesWithAll.count {
            let childVC = CategorySubViewController()
            childVC.pcatelogId = pcatelogId
            childVC.catelogId = categoriesWithAll[index].catelogId
            addChild(childVC)
            scrollView.addSubview(childVC.view)
            childVC.view.frame = CGRect(x: CGFloat(index) * UIScreen.width, y: 0, width: UIScreen.width, height: scrollView.height)
            childVCs.append(childVC)
        }
        scrollView.contentSize = CGSize(width: UIScreen.width * CGFloat(categoriesWithAll.count), height: 0)
        scrollView.contentOffset = CGPoint(x: CGFloat(initialIndex) * UIScreen.width, y: 0)
    }
    
    @objc private func _gotoSearchViewController() {
        SearchViewController.show()
    }
    
}

extension CategorySubContainer: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / UIScreen.width)
        segmentioView.selectedIndex = page
    }
    
}
