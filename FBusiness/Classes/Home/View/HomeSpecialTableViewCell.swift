//
//  HomeSpecialTableViewCell.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster

class HomeSpecialTableViewCell: UITableViewCell {

    private static let thumbHeight: CGFloat = (24 / 75) * UIScreen.width
    static let height: CGFloat = HomeSpecialCollectionViewCell.size.height + HomeSpecialTableViewCell.thumbHeight + 20

    @IBOutlet weak var view0HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var view0ImageView: UIImageView!
    @IBOutlet weak var view1: UIView!
    private lazy var collectionView: UICollectionView = {
        let flowLayout = XCarouselFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.spacingMode = .fixed(spacing: 25)
        flowLayout.itemSize = HomeSpecialCollectionViewCell.size
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        cv.register(UINib(nibName: "HomeSpecialCollectionViewCell", bundle: Bundle.currentHome), forCellWithReuseIdentifier: NSStringFromClass(HomeSpecialCollectionViewCell.self))
        cv.backgroundColor = UIColor.clear
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    var products: [ProductModel] = [ProductModel]() {
        didSet {
            collectionView.reloadData()
            if products.count >= 3 {
                collectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view0HeightConstraint.constant = HomeSpecialTableViewCell.thumbHeight

        view1.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0))
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension HomeSpecialTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(HomeSpecialCollectionViewCell.self), for: indexPath) as? HomeSpecialCollectionViewCell {
            cell.model = products[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
}

extension HomeSpecialTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        GoodsDetailViewController.show(with: products[indexPath.row].productId)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return HomeSeckillCollectionViewCell.size
    }
    
}

class HomeSpecialCollectionViewCell: UICollectionViewCell {
    
    static let size = CGSize(width: 130, height: 180)
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceDiscountLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    private var carModel: CarModel?
    var model: ProductModel? {
        didSet {
            if let model = self.model {
                imageView.kf_setImage(urlString: model.productThumbUrl, placeholder: Constants.defaultPlaceHolder)
                nameLabel.text = model.productName ?? ""
                let attributedString = NSMutableAttributedString(string: String(format: "￥%.2f", model.productPrice ?? 0), attributes: [NSAttributedString.Key.strikethroughStyle: 1])
                priceLabel.attributedText = attributedString
                priceDiscountLabel.text = String(format: "￥%.2f", model.productSpecialPrice ?? model.productDiscountPrice ?? model.productPrice ?? 0)
                priceLabel.isHidden = priceDiscountLabel.text?.contains(attributedString.string) ?? false
                carModel = CarVModel.default.model(for: model.productId)

                if model.productStatus ?? .normal != .normal || model.stock ?? 0 == 0 {
                    stockLabel.isHidden = false
                    addButton.isHidden = true
                } else {
                    stockLabel.isHidden = true
                    addButton.isHidden = false
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        priceLabel.adjustsFontSizeToFitWidth = true
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOpacity = 0.7
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        UserVModel.default.verify { [weak self] (success) in
            if success {
                guard let model = self?.model else { return }
                CarVModel.default.add(model.productId, 1)
            }
        }
    }
}
