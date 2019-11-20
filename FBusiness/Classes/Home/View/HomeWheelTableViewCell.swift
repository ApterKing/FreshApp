//
//  HomeWheelTableViewCell.swift
//  FBusiness
//
//

import UIKit
import SwiftX

class HomeWheelTableViewCell: UITableViewCell {
    
    static let height: CGFloat = 180
    
    private lazy var wheelView: XWheelView = {
        let wheel = XWheelView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: HomeWheelTableViewCell.height))
        wheel.register(HomeWheelCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(HomeWheelCollectionViewCell.self))
        wheel.dataSource = self
        wheel.delegate = self
        return wheel
    }()
    
    var configs = [ConfigModel]() {
        didSet {
            wheelView.pageControl.y = wheelView.height - 15
            wheelView.pageControl.numberOfPages = configs.count
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addSubview(wheelView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        wheelView.frame = bounds
    }
    
}

extension HomeWheelTableViewCell: XWheelViewDataSource {
    
    func numberOfItems(in wheelView: XWheelView) -> Int {
        return configs.count
    }
    
    func wheelView(_ wheelView: XWheelView, cellForItemAt index: Int) -> UICollectionViewCell {
        if let cell = wheelView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(HomeWheelCollectionViewCell.self), for: index) as? HomeWheelCollectionViewCell {
            if index < configs.count {
                cell.imageView.kf_setImage(urlString: configs[index].configImgUrl, placeholder: Constants.defaultPlaceHolder)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
}

extension HomeWheelTableViewCell: XWheelViewDelegate {
    
    func wheelView(_ wheelView: XWheelView, didSelectItemAt index: Int) {
        let config = configs[index]
        let dataType = ConfigModel.DataType(rawValue: config.configDataType) ?? .unknown
        switch dataType {
        case .products:
            // 从分类中找到对应的二级推荐
            if let datas = CategoryVModel.default.local(URLPath.Product.category, nil, to: [CategoryModel].self) {
                for data in datas {
                    let categories = data.subs ?? []
                    for (index, subModel) in categories.enumerated() {
                        print("fuckxxxxx  products   \(subModel.catelogId)  \(config.data)   \(subModel.catelogId == config.data)")
                        if subModel.catelogId == config.data {
                            CategorySubContainer.show(index + 1, categories, data.catelogId)
                            break
                        }
                    }
                }
            }
        case .catelogs:
            if let datas = CategoryVModel.default.local(URLPath.Product.category, nil, to: [CategoryModel].self) {
                for data in datas {
                    if data.catelogId == config.data {
                        print("fuckxxxxx  catelogs \(data.catelogId)  \(config.data)   \(data.catelogId == config.data)")
                        CategorySubContainer.show(0, data.subs ?? [], config.data)
                        break
                    }
                }
            }
        case .product:
            print("fuckxxxxx  product \(config.data)")
            GoodsDetailViewController.show(with: config.data)
        default:
            break
        }
    }
    
}

fileprivate class HomeWheelCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView = {
        let imgv = UIImageView()
        imgv.contentMode = .scaleAspectFill
        imgv.clipsToBounds = true
        return imgv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
}
