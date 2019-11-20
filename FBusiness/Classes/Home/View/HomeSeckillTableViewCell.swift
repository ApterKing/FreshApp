//
//  HomeSeckillTableViewCell.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster

class HomeSeckillTableViewCell: UITableViewCell {

    private static let thumbHeight: CGFloat = (24 / 75) * UIScreen.width
    static let height: CGFloat = HomeSeckillCollectionViewCell.size.height + HomeSeckillTableViewCell.thumbHeight + 30
    
    @IBOutlet weak var thumbHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!

    var recommend: RecommendModel? {
        didSet {
            if let model = recommend {
                thumbImageView.kf_setImage(url: URL(string: model.recommendThumbUrl), placeholder: nil)
                products = model.products ?? []
            }
        }
    }
    private var products: [ProductModel] = [ProductModel]() {
        didSet {
            collectionView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        thumbHeightConstraint.constant = HomeSeckillTableViewCell.thumbHeight
        thumbImageView.clipsToBounds = true
        thumbImageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        thumbImageView.addGestureRecognizer(gesture)
        _ = gesture.rx.event
            .subscribe(onNext: { [weak self] (_) in
                guard let weakSelf = self else { return }
                let vc = HomeMoreViewController()
                vc.titleString = weakSelf.recommend?.recommendName ?? ""
                vc.recommendId = weakSelf.recommend?.recommendId ?? ""
                vc.hidesBottomBarWhenPushed = true
                topNavigationController?.pushViewController(vc, animated: true)
            })

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "HomeSeckillCollectionViewCell", bundle: Bundle.currentHome), forCellWithReuseIdentifier: NSStringFromClass(HomeSeckillCollectionViewCell.self))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {

    }
}

extension HomeSeckillTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(HomeSeckillCollectionViewCell.self), for: indexPath) as? HomeSeckillCollectionViewCell {
            cell.model = products[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
}

extension HomeSeckillTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        GoodsDetailViewController.show(with: products[indexPath.row].productId)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return HomeSeckillCollectionViewCell.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
}

class HomeSeckillCollectionViewCell: UICollectionViewCell {
    
    static let size: CGSize = CGSize(width: (UIScreen.width - 20 - 15 * 3) / 3.1, height: 185)
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceDiscountLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var model: ProductModel? {
        didSet {
            if let model = self.model {
                imageView.kf_setImage(urlString: model.productThumbUrl, placeholder: Constants.defaultPlaceHolder)
                let attributedString = NSMutableAttributedString(string: String(format: "￥%.2f", model.productPrice ?? 0), attributes: [NSAttributedString.Key.strikethroughStyle: 1])
                nameLabel.text = model.productName ?? ""
//                unitLabel.text = "\(model.productWeight ?? 0) \(model.productUnit ?? "")"
                priceLabel.attributedText = attributedString
                priceLabel.adjustsFontSizeToFitWidth = true
                priceDiscountLabel.text = String(format: "￥%.2f", model.productDiscountPrice ?? 0)
                priceLabel.isHidden = priceDiscountLabel.text?.contains(attributedString.string) ?? false

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
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        UserVModel.default.verify { (success) in
            if success {
                guard let model = self.model else { return }
                CarVModel.default.checkStock(product: model, complection: { (success) in
                    if success {
                        CarVModel.default.add(model.productId, 1)
                    }
                })
            }
        }
    }
}
