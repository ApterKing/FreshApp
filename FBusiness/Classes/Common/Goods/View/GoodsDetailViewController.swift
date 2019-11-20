//
//  GoodsDetailViewController.swift
//  FBusiness
//
//

import UIKit
import Kingfisher
import SwiftX
import Toaster

public class GoodsDetailViewController: BaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topHeightConstraint: NSLayoutConstraint!
    private lazy var wheelView: XWheelView = {
        let wheel = XWheelView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: topHeightConstraint.constant))
        wheel.register(GoodsDetailCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(GoodsDetailCollectionViewCell.self))
        wheel.dataSource = self
        wheel.delegate = self
        wheel.backgroundColor = UIColor.white
        return wheel
    }()
    @IBOutlet weak var pageLabel: UILabel!
    
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var centerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var specialTagView: UIView!
    @IBOutlet weak var specialTagLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceDiscountLabel: UILabel!
    @IBOutlet weak var priceDiscountLeading: NSLayoutConstraint!
    
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var specialView: UIView!
    @IBOutlet weak var specialHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var specialLabel: UILabel!
    
    private var contentHeight: CGFloat = 0  // 出去底部的内容高度
    
    @IBOutlet weak var bottomView: UIView!
    private lazy var webView: UIWebView = {
        let web = UIWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 100))
        web.dataDetectorTypes = UIDataDetectorTypes(rawValue: 0)
        web.scrollView.isUserInteractionEnabled = false
        web.scrollView.showsVerticalScrollIndicator = false
        web.scrollView.showsHorizontalScrollIndicator = false
        return web
    }()
    
    private var productId: String?
    private var model: ProductModel?
    private var carModel: CarModel?
    private let vmodel = GoodsVModel()
    private var resources: [ProductModel.Resource] = []
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
        _loadData()
    }

    deinit {
        print("GoodsDetailViewController   deinit")
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        UserVModel.default.verify { [weak self] (success) in
            if success {
                self?._buttonAction(sender)
            }
        }
    }
    
    public override func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool {
        return true
    }
    
    public override func loadingViewDidTapped(_ loadingView: XLoadingView) {
        _loadData()
    }
    
    public override func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage? {
        return UIImage(named: "icon_order_canceled_empty", in: Bundle.currentBase, compatibleWith: nil)
    }
    
    public override func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "服务器连接错误\n请检查网络设置~", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        case .empty:
            return NSAttributedString(string: "获取商品详情失败，点击重试", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
    
}

extension GoodsDetailViewController {
    
    private func _initUI() {
        navigationItem.title = "商品详情"

//        let options: [UIControlStateOption] = [.title("分享", UIColor(hexColor: "#66B30C"), .normal),
//                                               .title("分享", UIColor(hexColor: "#a0a0a5"), .disabled),
//                                               .title("分享", UIColor(hexColor: "#66B30C").withAlphaComponent(0.7), .highlighted)
//        ]
//        navigationItem.rightBarButtonItem = customBarButtonItem(options: options, size: CGSize(width: 60, height: 44), isBackItem: false, left: false, handler: { [weak self] (_) in
//            guard let product = self?.model,
//                WXApi.isWXAppInstalled() && WXApi.isWXAppSupport(), let resources = product.resources, resources.count != 0, let urlPath = resources[0].resourceUrl, let url = URL(string: urlPath) else { return }
//            ImageDownloader.default.downloadImage(with: url, options: nil, progressBlock: nil, completionHandler: { (result) in
//                switch result {
//                case .success(let imageLoading /*ImageLoadingResult*/):
//                    if let data = imageLoading.image.compress(toData: 100 * 1000) {
//                        let wxMiniObject = WXMiniProgramObject()
//                        wxMiniObject.webpageUrl = "http:/d.3xian.shop"
//                        wxMiniObject.userName = "gh_d5a70403da20"
//                        #if DEBUG
//                        wxMiniObject.miniProgramType = WXMiniProgramType.preview
//                        #else
//                        wxMiniObject.miniProgramType = WXMiniProgramType.release
//                        #endif
//                        wxMiniObject.path = "pages/classify/products/details/index?id=\(product.productId)&code=\(UserVModel.default.currentUser?.userInviteCode ?? "")"
//                        wxMiniObject.hdImageData = data
//                        let message = WXMediaMessage()
//                        message.title = product.productName ?? ""
//                        message.description = product.productDescription ?? ""
//                        message.mediaObject = wxMiniObject
//                        let req = SendMessageToWXReq()
//                        req.message = message
//                        WXApi.send(req)
//                    } else {
//                        Toast.show("分享预览图下载失败")
//                    }
//                default:
//                    Toast.show("分享预览图下载失败")
//                }
//            })
//        })

        topView.insertSubview(wheelView, belowSubview: pageLabel)
        
        bottomView.addSubview(webView)
        _ = webView.scrollView.rx.observe(CGSize.self, "contentSize")
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (size) in
                guard let weakSelf = self, let contentSize = size else { return }
                weakSelf.contentHeightConstraint.constant = weakSelf.contentHeight + contentSize.height + 40
                print("fuck ----- here   \(weakSelf.contentHeight)     \(contentSize.height)   \(weakSelf.contentHeightConstraint.constant)")
                weakSelf.scrollView.contentSize = CGSize(width: UIScreen.width, height: weakSelf.contentHeight + contentSize.height + 40)
                
                weakSelf.webView.height = contentSize.height
            })
        
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        specialTagView.addGestureRecognizer(gesture)
        _ = gesture.rx.event
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { (_) in
                #if FRESH_CLIENT
                CategoryPrivilegeViewController.show()
                #endif
            })

        Theme.decorate(button: addButton, font: UIFont.systemFont(ofSize: 14), color: UIColor(hexColor: "#66B30C"), cornerRadius: 15)
    }
    
    private func _loadData() {
        guard let productId = self.productId else { return }
        loadingView.state = .loading
        loadingView.isHidden = false
        vmodel.fetch(productId) { [weak self] (model, error) in
            guard let weakSelf = self else { return }
            if let model = model {
                weakSelf.loadingView.isHidden = true
                weakSelf.loadingView.state = .success
                weakSelf.model = model
                weakSelf._bindData()
            } else {
                weakSelf.loadingView.state = .error
            }

            weakSelf.vmodel.fetchDeliveryTime { (data, error) in
                if let model = data {
                    weakSelf.timeLabel.text = "最快 明天\(model.deliverStartTime)-\(model.deliverEndTime)送达"
                } else {
                    weakSelf.timeLabel.text = ""
                }
            }
        }
    }
    
    private func _bindData() {
        guard let model = self.model else { return }
        
        resources = model.resources ?? []
        if resources.count != 0 {
            wheelView.isHidden = false
            pageLabel.isHidden = false
            pageLabel.text = "1/\(resources.count)"
        } else {
            wheelView.isHidden = true
            pageLabel.isHidden = true
        }
        wheelView.reloadData()
        contentHeight = 260  // 300

        nameLabel.text = model.productName
        descLabel.text = model.productDescription

        let attributedString = NSMutableAttributedString(string: String(format: "￥%.2f", model.productPrice ?? 0), attributes: [NSAttributedString.Key.strikethroughStyle: 1])
        priceLabel.attributedText = attributedString

        centerHeightConstraint.constant = 168 + (descLabel.text?.heightWith(font: descLabel.font, limitWidth: UIScreen.width - 75) ?? 20)
        contentHeight += centerHeightConstraint.constant
        
        let productType =  ProductModel.ProductType(rawValue: model.productType ?? "") ?? .normal
        
        if productType != ProductModel.ProductType.normal {
            specialTagView.isHidden = false
            specialTagLabel.text = productType.description
            priceDiscountLeading.constant = 55
            if productType == ProductModel.ProductType.specialPrice {
                priceDiscountLabel.text = String(format: "￥%.2f\(model.formatProductUnit)", model.productSpecialPrice ?? model.productDiscountPrice ?? 0)
            } else {
                priceDiscountLabel.text = String(format: "￥%.2f\(model.formatProductUnit)", model.productDiscountPrice ?? 0)
            }
        } else {
            specialTagView.isHidden = true
            priceDiscountLeading.constant = 0
            priceDiscountLabel.text = String(format: "￥%.2f\(model.formatProductUnit)", model.productDiscountPrice ?? 0)
        }
        priceLabel.isHidden = priceDiscountLabel.text?.contains(attributedString.string) ?? false
        
        // 暂时不显示特价商品
        specialView.isHidden = model.productType != ProductModel.ProductType.specialPrice.rawValue
        specialHeightConstraint.constant = specialView.isHidden ? 0 : 36
        contentHeight += specialHeightConstraint.constant
        
        carModel = CarVModel.default.model(for: productId ?? "")
        if carModel != nil {
            controlView.isHidden = false
            addButton.isHidden = true
        } else {
            controlView.isHidden = true
            addButton.isHidden = false
        }
        _resetCountData()

        // 判定是否售罄
        if model.productStatus ?? .normal != .normal || (model.stock ?? 0) == 0 {
            controlView.isHidden = true
            addButton.isHidden = false
            addButton.isEnabled = false
            addButton.setTitle("已售罄", for: .normal)
        }

        // 判定是否显示暂停销售
        if CategoryVModel.default.shouldShowSuspendSalePrompt(levelTwo: model.pCatelogId) {
            controlView.isHidden = true
            addButton.isHidden = false
            addButton.isEnabled = false
            addButton.setTitle("暂停销售", for: .normal)
        }

        webView.loadHTMLString(_generateHtml(model.productContent ?? ""), baseURL: nil)
        
        contentHeightConstraint.constant = contentHeight + webView.height + 40
        scrollView.contentSize = CGSize(width: UIScreen.width, height: contentHeight + webView.height + 40)
    }
    
    private func _generateHtml(_ body: String) -> String {
        var htmlString = "<html><head><style type=\"text/css\">img{max-width:100%;height:auto}body{font-size:16px;}</style></head>"
        htmlString.append("<body>")
        htmlString.append(body)
        htmlString.append("<div style=\"width:100%;color:#49b686;text-align:center;font-size:18px;font-weight:bold;margin-top:5px\">三鲜在手，生活无忧</div><div style=\"width:100%;color:black;text-align:left;font-size:14px;margin-top:5px\"><span style=\"font-weight:bold\">放心食材：</span><span style=\"color:#888888\">全球原料直采，有机种植，优质产地，生产原料可追溯。</span></div><div style=\"width:100%;color:black;text-align:left;font-size:14px;margin-top:5px\"><span style=\"font-weight:bold\">配送服务：</span><span style=\"color:#888888\">智能配送系统，高质量、高品质服务态度。</span></div><div style=\"width:100%;color:black;text-align:left;font-size:14px;margin-top:5px\"><span style=\"font-weight:bold\">售后无忧：</span><span style=\"color:#888888\">商品任何质量问题，可拨打客服电话：</span><span style=\"color:#49b686\">0825-2323198</span></div><div style=\"width:100%;color:#49b686;text-align:center;font-size:18px;font-weight:bold;margin-top:5px\">价格说明</div><div style=\"font-size:14px;margin-top:5px;color:#888888;line-height:20px;margin-bottom:50px\">商品价格，是指商品在三鲜生活 App 上的销售价格，具体的成交价格，可能会因为用户使用优惠券、会员信誉度所享受的折扣、货源品质而有所不同，最终以结算价格为准。</div><div style='font-size:10px;margin-top:5px;color:#888888;line-height:20px;margin-bottom:50px;text-align:center'>图片仅供参考，商品以收到实物为准。</div>")
        htmlString.append("</body></html>")
        return htmlString
    }
    
    private func _resetCountData() {
        guard let model = self.carModel else { return }
        countLabel.text = "\(model.count)"
    }
    
    private func _buttonAction(_ sender: UIButton) {
        guard let model = self.model else { return }
        if sender.tag == 0 {  // -
            guard let carModel = self.carModel else { return }
            if carModel.count > 1 {
                carModel.count -= 1
                CarVModel.default.edit([carModel.cartId: carModel.count])
            }
            _resetCountData()
        } else if sender.tag == 1 {  // +
            guard (model.stock ?? 0) > (carModel?.count ?? 0) && carModel?.productStatus ?? .normal == .normal else {
                Toast.show("库存不足")
                return
            }
            CarVModel.default.checkStock(product: model) { [weak self] (success) in
                if success {
                    self?.carModel?.count += 1
                    CarVModel.default.add(model.productId, 1, true, false, nil)
                    self?._resetCountData()
                }
            }
        } else {  // 加入购物车
            guard (model.stock ?? 0) != 0 && carModel?.productStatus ?? .normal == .normal else { return }
            startHUDAnimation()
            CarVModel.default.add(model.productId, 1, false) { [weak self] (_, error) in
                if error == nil {
                    CarVModel.default.fetch({ (_) in
                        self?.stopHUDAnimation()
                        self?.carModel = CarVModel.default.model(for: model.productId)
                        self?._bindData()
                    })
                } else {
                    self?.stopHUDAnimation()
                }
            }
        }
    }
}

extension GoodsDetailViewController {
    
    static public func show(with productId: String) {
        let vc = GoodsDetailViewController(nibName: "GoodsDetailViewController", bundle: Bundle(for: GoodsDetailViewController.self))
        vc.productId = productId
        vc.hidesBottomBarWhenPushed = true
        topNavigationController?.pushViewController(vc, animated: true)
    }
    
}

extension GoodsDetailViewController: XWheelViewDataSource {
    
    public func numberOfItems(in wheelView: XWheelView) -> Int {
        return resources.count
    }
    
    public func wheelView(_ wheelView: XWheelView, cellForItemAt index: Int) -> UICollectionViewCell {
        if let cell = wheelView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(GoodsDetailCollectionViewCell.self), for: index) as? GoodsDetailCollectionViewCell {
            if index < resources.count {
                cell.imageView.kf_setImage(urlString: resources[index].resourceUrl, placeholder: Constants.defaultPlaceHolder)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
}

extension GoodsDetailViewController: XWheelViewDelegate {
    
    public func wheelView(_ wheelView: XWheelView, didScrollTo index: Int) {
        pageLabel.text = "\(index + 1)/\(resources.count)"
    }
    
}

fileprivate class GoodsDetailCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
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

