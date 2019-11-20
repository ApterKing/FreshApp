//
//  FlowCashApplyView.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import Toaster

class FlowCashApplyView: UIView {
    
    typealias ApplyHandler = ((_ money: Float) -> Void)

    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var applyBottomConstraint: NSLayoutConstraint!
    
    var handler: ApplyHandler?
    
    private var contentViewHeight: CGFloat {
        return 270 + FlowCashApplyCell.height + UIScreen.homeIndicatorMoreHeight
    }
    private var datas: [Float] = WithdrawVModel.default.currentWithdraw ?? [30, 50, 100]
    
    class func loadFromXib() -> FlowCashApplyView {
        if let view = Bundle.currentMine.loadNibNamed("FlowCashApplyView", owner: self, options: nil)?.first as? FlowCashApplyView {
            view.frame = UIScreen.main.bounds
            view.contentBottomConstraint.constant = -view.contentViewHeight
            return view
        }
        return FlowCashApplyView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        opacityView.alpha = 0.01
        contentHeightConstraint.constant = contentViewHeight
        contentBottomConstraint.constant = -contentViewHeight
        applyBottomConstraint.constant = 20 + UIScreen.homeIndicatorMoreHeight
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(FlowCashApplyCell.self, forCellWithReuseIdentifier: NSStringFromClass(FlowCashApplyCell.self))
        
        if datas[0] <= (UserVModel.default.currentUser?.userBalance ?? 0) {
            collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .right)
        }

        Theme.decorate(button: applyButton, cornerRadius: 5)
        
        WithdrawVModel.default.fetch { [weak self] (_) in
            guard let weakSelf = self else { return }
            self?.collectionView.reloadData()

            if weakSelf.datas[0] <= (UserVModel.default.currentUser?.userBalance ?? 0) {
                weakSelf.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .right)
            }
        }
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        _dismiss()
        if sender.tag == 1 {
            if let items = collectionView.indexPathsForSelectedItems, items.count != 0, let row = items.first?.row {
                handler?(datas[row])
            }
        }
    }
    
}

extension FlowCashApplyView {
    
    private func _show() {
        self.frame = topViewController?.view.bounds ?? UIScreen.main.bounds
        topViewController?.view.addSubview(self)
        opacityView.alpha = 0.01
        contentBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.opacityView.alpha = 0.7
            self.layoutIfNeeded()
        }
    }
    
    private func _dismiss(_ agreed: Bool = false) {
        contentBottomConstraint.constant = -contentViewHeight
        UIView.animate(withDuration: 0.25, animations: {
            self.opacityView.alpha = 0.01
            self.layoutIfNeeded()
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
}

extension FlowCashApplyView {
    
    func show() {
        _show()
    }
    
    func dismiss() {
        _dismiss()
    }
    
}

extension FlowCashApplyView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(FlowCashApplyCell.self), for: indexPath) as? FlowCashApplyCell {
            cell.textLabel.text = String(format: "￥%.f", datas[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
}

extension FlowCashApplyView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: FlowCashApplyCell.height, height: FlowCashApplyCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ((UIScreen.width - 60) - CGFloat(datas.count) * FlowCashApplyCell.height) / CGFloat(datas.count - 1) - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard datas[indexPath.row] <= (UserVModel.default.currentUser?.userBalance ?? 0) else {
            Toast.show("账户余额不足，继续努力吧")
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
    }
    
}

extension FlowCashApplyView {
    
    class FlowCashApplyCell: UICollectionViewCell {
        
        static let height: CGFloat = 80
        
        lazy var textLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 20)
            label.backgroundColor = UIColor.white
            label.textColor = UIColor(hexColor: "#666666")
            label.highlightedTextColor = UIColor(hexColor: "#66B30C")
            label.layer.cornerRadius = 8
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            label.clipsToBounds = true
            return label
        }()
        lazy var borderView: UIImageView = {
            let view = UIImageView()
            view.image = UIImage(color: UIColor(hexColor: "#666666"))
            view.highlightedImage = UIImage(color: UIColor(hexColor: "#66B30C"))
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
            return view
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.addSubview(borderView)
            borderView.snp.makeConstraints {
                $0.edges.equalTo(0)
            }
            contentView.addSubview(textLabel)
            textLabel.snp.makeConstraints {
                $0.edges.equalTo(UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
