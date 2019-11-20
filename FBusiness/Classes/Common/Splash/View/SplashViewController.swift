//
//  SplashViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX
import RxCocoa
import RxSwift

public class SplashViewController: BaseViewController {
    
    private static var window: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = true
        window.windowLevel = UIWindow.Level.statusBar + 0.1
        return window
    }()
    
    private lazy var opacityView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.black
        view.alpha = 0.7
        return view
    }()
    private lazy var wheelView: XWheelView = {
        let wheel = XWheelView(frame: UIScreen.main.bounds)
        wheel.register(SplashWheelCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(SplashWheelCollectionViewCell.self))
        wheel.backgroundColor = UIColor.clear
        wheel.dataSource = self
        wheel.delegate = self
        wheel.autoWheel = false
        wheel.cycle = false
        wheel.bounces = true
        return wheel
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("进入应用", for: .normal)
        button.addTarget(self, action: #selector(_dismiss), for: .touchUpInside)
        return button
    }()
    
    // 网络数据
    private var configs: [ConfigModel]?
    
    // 本地数据
    private var imageNames: [String] = ["bg_splash_0", "bg_splash_1", "bg_splash_2"]

    override public func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
    }
    
}

extension SplashViewController {
    
    private func _initUI() {
        view.backgroundColor = UIColor.clear
        view.addSubview(opacityView)
        view.addSubview(wheelView)
       
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.bottom.equalTo(-UIScreen.homeIndicatorMoreHeight - 50)
            $0.centerX.equalTo(view.snp.centerX)
            $0.size.equalTo(CGSize(width: 180, height: 40))
        }
        Theme.decorate(button: button, font: UIFont.systemFont(ofSize: 18), color: UIColor(hexColor: "#e32921"), cornerRadius: 5)

        configs = ConfigVModel.default.currentLaunch
        wheelView.reloadData()
        _ = ConfigVModel.default.currentLaunchRelay
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (launchs) in
                self?.configs = launchs
                self?.wheelView.reloadData()
            })
    }
    
    @objc private func _dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            SplashViewController.window.alpha = 0
        }) { (_) in
            SplashViewController.window.isHidden = true
            SplashViewController.window.rootViewController = nil
            SplashViewController.window.removeFromSuperview()
        }
    }
    
}

extension SplashViewController {
    
    static public func show() {
        guard ConfigVModel.default.currentLaunch.count != 0 else { return }
        let vc = SplashViewController()
        vc.configs = ConfigVModel.default.currentLaunch
        SplashViewController.window.rootViewController = vc
        SplashViewController.window.isHidden = false
    }
    
}

extension SplashViewController: XWheelViewDataSource {
    
    public func numberOfItems(in wheelView: XWheelView) -> Int {
        return configs?.count ?? 3
    }
    
    public func wheelView(_ wheelView: XWheelView, cellForItemAt index: Int) -> UICollectionViewCell {
        if let cell = wheelView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(SplashWheelCollectionViewCell.self), for: index) as? SplashWheelCollectionViewCell {
            if let imageUrl = configs?[index].configImgUrl {
                cell.imageView.kf_setImage(urlString: imageUrl, placeholder: Constants.defaultPlaceHolder)
            } else {
                cell.imageView.image = UIImage(named: imageNames[index], in: Bundle.currentCommon, compatibleWith: nil)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
}

extension SplashViewController: XWheelViewDelegate {
    
    public func wheelView(_ wheelView: XWheelView, didSelectItemAt index: Int) {
        guard let config = configs?[index] else { return }
        let dataType = ConfigModel.DataType(rawValue: config.configDataType) ?? .unknown
        switch dataType {
        case .products:
            // 从分类中找到对应的二级推荐
            if let datas = CategoryVModel.default.local(URLPath.Product.category, nil, to: [CategoryModel].self) {
                for data in datas {
                    let categories = data.subs ?? []
                    for (index, subModel) in categories.enumerated() {

                        print("fuckxxxxx   products  \(subModel.catelogId)  \(config.data)   \(subModel.catelogId == config.data)")
                        if subModel.catelogId == config.data {
                            _dismiss()
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
                        _dismiss()
                        CategorySubContainer.show(0, data.subs ?? [], config.data)
                        break
                    }
                }
            }
        case .product:
            _dismiss()
            print("fuckxxxxx  product \(config.data)")
            GoodsDetailViewController.show(with: config.data)
        default:
            break
        }
    }
    
    public func wheelViewDidEndDragging(_ wheelView: XWheelView, willDecelerate decelerate: Bool) {
        print("splash   \(wheelView.contentSize)    \(wheelView.contentOffset)    \(decelerate)")
    }
    
    public func wheelViewDidScroll(_ wheelView: XWheelView) {
        if wheelView.contentOffset.x <= 0 {
            wheelView.contentOffset = CGPoint.zero
        } else {
            let offsetY = wheelView.contentOffset.x + wheelView.width - wheelView.contentSize.width
            let detal = offsetY * 1.5 / UIScreen.width
            wheelView.alpha = 1 - detal / 3
            opacityView.alpha = 1 - detal
            print("fuck   wheelView DidScroll  \(wheelView.contentOffset.x)  \(wheelView.contentSize.width)  \(detal)   \(1-detal)")
            if offsetY > UIScreen.width / 6 {
                _dismiss()
            }
        }
    }

}

fileprivate class SplashWheelCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView = {
        let imgv = UIImageView()
        imgv.contentMode = .scaleAspectFill
        imgv.clipsToBounds = true
        return imgv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white
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
