//
//  HomeCategoryTableViewCell.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class HomeCategoryTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var categories: [CategoryModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.register(UINib(nibName: "HomeCategoryCollectionViewCell", bundle: Bundle.currentHome), forCellWithReuseIdentifier: NSStringFromClass(HomeCategoryCollectionViewCell.self))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension HomeCategoryTableViewCell {
    
    static func calculateHeight(_ categories: [CategoryModel]) -> CGFloat {
        let houseServiceEnable = CityVModel.default.currentCity?.config?.homeServiceFee ?? 0 != 0
        let count = categories.count + (houseServiceEnable ? 1 : 0)
        var lines = count % 5 == 0 ? count / 5 : count / 5 + 1
        if UIDevice.isIphone4_5() {
            lines = count % 4 == 0 ? count / 4 : count / 4 + 1
            return CGFloat(lines) * (UIScreen.width - 10 * 3) / 5.0 + (CGFloat(lines) - 1) * 10 + 30
        } else {
            return CGFloat(lines) * (UIScreen.width - 10 * 4) / 5.0 + (CGFloat(lines) - 1) * 10 + 30
        }
    }
    
}

extension HomeCategoryTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let houseServiceEnable = CityVModel.default.currentCity?.config?.homeServiceFee ?? 0 != 0
        return categories.count + (houseServiceEnable ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(HomeCategoryCollectionViewCell.self), for: indexPath) as? HomeCategoryCollectionViewCell {
            cell.model = nil
            if indexPath.row < categories.count {
                cell.model = categories[indexPath.row]
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
}

extension HomeCategoryTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if indexPath.row == categories.count {
            HouserKeepingAddViewController.show()
            return
        }
        
        // 从分类中找到对应的一级推荐
        let model = categories[indexPath.row]
        if let datas = CategoryVModel.default.local(URLPath.Product.category, nil, to: [CategoryModel].self) {
            var show = false
            for data in datas {
                if data.catelogId == model.catelogId {
                    show = true
                    CategorySubContainer.show(0, data.subs ?? [], data.catelogId)
                    break
                }
            }
            if show == false {
                CategorySubContainer.show(0, [], model.catelogId)
            }
        } else {
            CategorySubContainer.show(0, [], model.catelogId)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.isIphone4_5() {
            return CGSize(width: (UIScreen.width - 10 * 3) / 4.0 - 1, height: (UIScreen.width - 10 * 3) / 4.0)
        } else {
            return CGSize(width: (UIScreen.width - 10 * 4) / 5.0 - 1, height: (UIScreen.width - 10 * 4) / 5.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

class HomeCategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    var model: CategoryModel? {
        didSet {
            if let model = self.model {
                imageView.kf_setImage(urlString: model.catelogThumbUrl, placeholder: Constants.defaultPlaceHolder)
                nameLabel.text = model.catelogName
            } else {
                imageView.image = UIImage(named: "icon_house_keeping", in: Bundle.currentBase, compatibleWith: nil)
                nameLabel.text = "家政服务"
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
