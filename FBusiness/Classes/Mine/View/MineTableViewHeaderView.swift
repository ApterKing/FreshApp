//
//  MineTableViewswift
//  FBusiness
//
//

import UIKit
import SwiftX
import RxSwift
import RxCocoa
import Toaster

class MineTableViewHeaderView: UIView {

    @IBOutlet weak var greenTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headWhiteImageView: UIImageView!
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var inviteCodeLabel: UILabel!
    @IBOutlet weak var trustAccountLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let orderStatus: [OrderModel.Status] = [
        .unpaid, .undeliver, .delivering, .finished, .canceled
    ]
    
    class func loadFromXib() -> MineTableViewHeaderView {
        
        if let view = Bundle.currentHome.loadNibNamed("MineTableViewHeaderView", owner: self, options: nil)?.first as? MineTableViewHeaderView {
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: 390)
            return view
        }
        return MineTableViewHeaderView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageTopConstraint.constant = UIScreen.statusBarHeight
        headWhiteImageView.isUserInteractionEnabled = true
        let gesture0 = UITapGestureRecognizer(target: self, action: nil)
        headWhiteImageView.addGestureRecognizer(gesture0)
        _ = gesture0.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { (_) in
                LoginViewController.show()
            })
        
        headImageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        headImageView.addGestureRecognizer(gesture)
        _ = gesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { (_) in
                LoginViewController.show()
            })
        
        let copyGesture = UITapGestureRecognizer(target: self, action: nil)
        inviteCodeLabel.addGestureRecognizer(copyGesture)
        _ = copyGesture.rx.event.asObservable()
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { (_) in
                let pasteboard = UIPasteboard.general
                pasteboard.string = UserVModel.default.currentUser?.userInviteCode ?? ""
                Toast.show("复制成功")
            })
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "MineCollectionViewCell", bundle: Bundle.currentMine), forCellWithReuseIdentifier: NSStringFromClass(MineCollectionViewCell.self))
        
        _ = NotificationCenter.default.rx.notification(Constants.notification_userInfo_changed)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                self?.resetInfo()
            })
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        if sender.tag == 0 {  // 消息
            MessageViewController.show()
        } else if sender.tag == 1 {  // 编辑
            
        } else if sender.tag == 2 {  // 奖金提示
            RewardIntroViewController.show()
        } else {  // 查看全部
            OrderSubContainer.show()
        }
    }
    
}

extension MineTableViewHeaderView {
    
    func updateUI(by detal: CGFloat) {
        greenTopConstraint.constant = detal < 0 ? detal : 0
    }
    
    func resetInfo() {
        inviteCodeLabel.isHidden = !UserVModel.default.isLogined
        inviteButton.isHidden = !UserVModel.default.isLogined
        
        trustAccountLabel.isHidden = UserVModel.default.currentUser?.config?.trustAccount == nil
        
        nicknameLabel.text = UserVModel.default.currentUser?.userName ?? "请登录"
        headImageView.kf_setImage(urlString: UserVModel.default.currentUser?.userThumb, placeholder: UIImage(named: "icon_mine_head", in: Bundle.currentMine, compatibleWith: nil))
        let inviteCode = UserVModel.default.currentUser?.userInviteCode ?? " "
        let text = "我的邀请码：\(inviteCode)"
        let attributeString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        let range = NSRange(location: 0, length: 6)
        attributeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexColor: "#333333")], range: range)
        inviteCodeLabel.attributedText = attributeString
        
        trustAccountLabel.text = String(format: "账期金额: ￥%.2f  账期时长: %d天", UserVModel.default.currentUser?.config?.trustAccount?.maxBanlance ?? 0, UserVModel.default.currentUser?.config?.trustAccount?.maxPeriod ?? 0)
    }
}

extension MineTableViewHeaderView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderStatus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(MineCollectionViewCell.self), for: indexPath) as? MineCollectionViewCell {
            cell.imageView.image = orderStatus[indexPath.row].icon
            cell.titleLabel.text = orderStatus[indexPath.row].description
            return cell
        }
        return UICollectionViewCell()
    }
    
}

extension MineTableViewHeaderView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        OrderSubContainer.show(with: orderStatus[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.width - 10 * 4) / 5.0, height: collectionView.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
