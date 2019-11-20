//
//  CategoryPrivilegeView.swift
//  FBusiness
//
//

import UIKit

class CategoryPrivilegeView: UIView {
    
    @IBOutlet weak var view2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var view2TableView: UITableView!
    
    @IBOutlet weak var view3HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var view3TableView: UITableView!
    
    private var categoryDatas: [CategoryModel] = []
    private var discountDatas: [CategoryModel] = []
    
    public var contentHeight: CGFloat = 0
    
    class func loadFromXib() -> CategoryPrivilegeView {
        
        if let view = Bundle.currentCategory.loadNibNamed("CategoryPrivilegeView", owner: self, options: nil)?.first as? CategoryPrivilegeView {
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: 0)
            return view
        }
        return CategoryPrivilegeView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        view2TableView.register(UINib(nibName: "PrivilegeTableViewCell", bundle: Bundle.currentCategory), forCellReuseIdentifier: NSStringFromClass(PrivilegeTableViewCell.self))
        view3TableView.register(UINib(nibName: "PrivilegeTableViewCell", bundle: Bundle.currentCategory), forCellReuseIdentifier: NSStringFromClass(PrivilegeTableViewCell.self))

        contentHeight = 160 + 145

        for data in CategoryVModel.default.datas {
            if data.config != nil {
                categoryDatas.append(data)
            }
        }
        view2HeightConstraint.constant = CGFloat(categoryDatas.count) * PrivilegeTableViewCell.height + 120
        contentHeight += view2HeightConstraint.constant

        for discount in UserVModel.default.currentUser?.config?.discounts ?? [] {
            for data in CategoryVModel.default.datas {
                if data.catelogId == discount.catelogId {
                    data.discount = discount
                    discountDatas.append(data)
                    break
                }
            }
        }
        view3HeightConstraint.constant = CGFloat(discountDatas.count) * PrivilegeTableViewCell.height + 145
        contentHeight += view3HeightConstraint.constant + 20
    }

}

extension CategoryPrivilegeView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == view2TableView {
            return categoryDatas.count
        } else {
            return discountDatas.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PrivilegeTableViewCell.self)) as? PrivilegeTableViewCell {
            cell.selectionStyle = .none
            if tableView == view2TableView {
                cell.model = categoryDatas[indexPath.row]
            } else {
                cell.model = discountDatas[indexPath.row]
            }
            return cell
        }
        return UITableViewCell()
    }
    
}

extension CategoryPrivilegeView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PrivilegeTableViewCell.height
    }
    
}
