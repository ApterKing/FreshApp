//
//  CategoryViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import RxSwift
import RxCocoa
import SnapKit
import Kingfisher

public class CategoryViewController: BaseViewController {
    
    private let tableViewWidth: CGFloat = 110
    private lazy var tableView: UITableView = {
        let tv = UITableView.default
        tv.register(UINib(nibName: "CategoryTableViewCell", bundle: Bundle.currentCategory), forCellReuseIdentifier: NSStringFromClass(CategoryTableViewCell.self))
        tv.backgroundColor = UIColor(hexColor: "#f7f7f7")
        tv.showsVerticalScrollIndicator = false
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView.default
        cv.register(CategoryCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(CategoryCollectionReusableView.self))
        cv.register(UINib(nibName: "CategoryCollectionViewCell", bundle: Bundle.currentCategory), forCellWithReuseIdentifier: NSStringFromClass(CategoryCollectionViewCell.self))
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.darkText
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    private lazy var discountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(hexColor: "#ED9E32")
        label.font = UIFont.systemFont(ofSize: 13)
        label.isUserInteractionEnabled = true
        return label
    }()
    private lazy var imageView: UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "icon_info_orange", in: Bundle.currentBase, compatibleWith: nil)
        imgv.isUserInteractionEnabled = true
        imgv.isHidden = true
        return imgv
    }()
    
    let vmodel = CategoryVModel()
    var selectedIndexPath: IndexPath?
    public var outterSelectedRow: Int = 0 {
        didSet {
            guard outterSelectedRow < vmodel.datas.count else { return }
            let indexPath = IndexPath(row: outterSelectedRow, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            selectedIndexPath = indexPath
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        _init()
        _loadData()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension CategoryViewController {
    
    private func _init() {
        let searchBar = XSearchBar()
        searchBar.editable = false
        searchBar.placeholder = "请输入关键字搜索"
        navigationItem.titleView = searchBar
        let gesture = UITapGestureRecognizer(target: self, action: #selector(_gotoSearchViewController))
        searchBar.addGestureRecognizer(gesture)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.left.bottom.equalTo(0)
            $0.width.equalTo(tableViewWidth)
        }
        
        let topView = UIView()
        view.addSubview(topView)
        topView.snp.makeConstraints {
            $0.left.equalTo(tableView.snp.right)
            $0.top.right.equalTo(0)
            $0.height.equalTo(60)
        }
        
        let discountGesture = UITapGestureRecognizer(target: self, action: #selector(_gotoPrivilegeController))
        discountLabel.addGestureRecognizer(discountGesture)
        topView.addSubview(discountLabel)
        discountLabel.snp.makeConstraints {
            $0.center.equalTo(topView.snp.center)
        }
        topView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.centerY.equalTo(topView.snp.centerY)
            $0.right.equalTo(discountLabel.snp.left).offset(-5)
        }
        let infoGesture = UITapGestureRecognizer(target: self, action: #selector(_gotoPrivilegeController))
        imageView.addGestureRecognizer(infoGesture)
        topView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerY.equalTo(topView.snp.centerY)
            $0.left.equalTo(discountLabel.snp.right).offset(5)
            $0.size.equalTo(CGSize(width: 18, height: 18))
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.right.bottom.equalTo(0)
            $0.left.equalTo(tableView.snp.right)
        }
        
        _ = NotificationCenter.default.rx.notification(Constants.notification_city_changed)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?._loadData(false)
            })
        
        _ = NotificationCenter.default.rx.notification(Constants.notification_userInfo_changed)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.tableView.reloadData()
                self?.collectionView.reloadData()
                
                if let indexPath = self?.selectedIndexPath {
                    self?._selected(indexPath)
                }
            })
        
        _ = NotificationCenter.default.rx.notification(Constants.notification_tabbar_selectedIndex_changed)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                if let selectedIndex = notification.object as? Int, selectedIndex == 1 {
                    self?._loadData(false)
                }
            })
    }
    
    private func _loadData(_ shouldShowLoadingView: Bool = true) {
        if shouldShowLoadingView {
            startAnimation()
        }
        vmodel.fetch { [weak self] (error) in
            guard let weakSelf = self else { return }
            weakSelf.stopAnimation()
            if error != nil {
            } else {
                weakSelf.tableView.reloadData()
                if weakSelf.vmodel.datas.count != 0 {
                    let indexPath = (weakSelf.selectedIndexPath?.row ?? 0 == 0 || weakSelf.selectedIndexPath?.row ?? 0 > weakSelf.vmodel.datas.count) ? IndexPath(row: 0, section: 0) : IndexPath(row: weakSelf.selectedIndexPath?.row ?? 0, section: 0)
                    weakSelf.selectedIndexPath = indexPath
                    weakSelf.nameLabel.text = weakSelf.vmodel.datas[0].catelogName
                    weakSelf.tableView.selectRow(at: weakSelf.selectedIndexPath, animated: true, scrollPosition: .none)
                    weakSelf.collectionView.reloadData()
                    weakSelf._selected(indexPath)
                }
            }
        }
    }
    
    @objc private func _gotoSearchViewController() {
        SearchViewController.show()
    }
    
    @objc private func _gotoPrivilegeController() {
        CategoryPrivilegeViewController.show()
    }
    
    private func _selected(_ indexPath: IndexPath) {
        let model = vmodel.datas[indexPath.row]
        nameLabel.text = model.catelogName
        if let config = model.config {
            discountLabel.text = String(format: "（享%.1f折优惠）", (config.discount ?? 0.9) * 10)
            imageView.isHidden = false
        } else if let discounts = UserVModel.default.currentUser?.config?.discounts {
            for (index, discount) in discounts.enumerated() {
                if discount.catelogId == model.catelogId {
                    discountLabel.text = String(format: "（专享%.1f折优惠）", (discount.discount ?? 0.9) * 10)
                    imageView.isHidden = false
                    break
                }
                if index == discounts.count - 1 {
                    discountLabel.text = ""
                    imageView.isHidden = true
                }
            }
        } else {
            discountLabel.text = ""
            imageView.isHidden = true
        }
    }
}

/// MARK: UITableView
extension CategoryViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vmodel.datas.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CategoryTableViewCell.self)) as? CategoryTableViewCell {
            cell.model = vmodel.datas[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
}

extension CategoryViewController: UITableViewDelegate {
   
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CategoryTableViewCell.height
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        _selected(indexPath)
        collectionView.reloadData()
    }
}

/// MARK: UICollectionView
extension CategoryViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let selectedIndexPath = selectedIndexPath else { return 0}
        return vmodel.datas[selectedIndexPath.row].subs?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let selectedIndexPath = selectedIndexPath, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CategoryCollectionViewCell.self), for: indexPath) as? CategoryCollectionViewCell {
            let model = vmodel.datas[selectedIndexPath.row].subs?[indexPath.row]
            cell.imageView.kf_setImage(urlString: model?.catelogThumbUrl, placeholder: Constants.defaultPlaceHolder)
            cell.titleLabel.text = model?.catelogName
            
            cell.imageWidthConstraint.constant = (UIScreen.width - tableViewWidth - 40) / 3.0 - 20
            return cell
        }
        return UICollectionViewCell()
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader, let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NSStringFromClass(CategoryCollectionReusableView.self), for: indexPath) as? CategoryCollectionReusableView {
            header.promptLabel.text = "水果每日 18:00-\(CityVModel.default.currentCity?.config?.orderDeadline ?? "21:00") 暂停销"
            return header
        }
        return UICollectionReusableView()
    }
}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let selectedIndexPath = selectedIndexPath else { return }

        let model = vmodel.datas[selectedIndexPath.row]
        CategorySubContainer.show(indexPath.row + 1, model.subs ?? [], model.catelogId)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.width - tableViewWidth - 40) / 3.0, height: (UIScreen.width - tableViewWidth - 40) / 3.0 + 20)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var showSuspendSalePrompt = false
        if let selectedIndexPath = selectedIndexPath {
            let model = vmodel.datas[selectedIndexPath.row]
            if CategoryVModel.default.shouldShowSuspendSaleHeaderPrompt(levelOne: model.catelogId) {
                showSuspendSalePrompt = true
            }
        }
        return CGSize(width: collectionView.width, height: showSuspendSalePrompt ? CategoryCollectionReusableView.height : 0)
    }

}
