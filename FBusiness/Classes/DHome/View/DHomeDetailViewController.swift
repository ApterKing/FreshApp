//
//  DHomeDetailViewController.swift
//  FBusiness
//
//  Created by wangcong on 2019/3/26.
//

import UIKit
import SwiftX
import Toaster

public class DHomeDetailViewController: BaseViewController {
    
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet weak var SNoLabel: UILabel!
    
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var mapContentView: UIView!
    @IBOutlet weak var mapContentHeightConstraint: NSLayoutConstraint!
    private let mapContentViewHeight = (UIScreen.width * 9 / 16)
    private lazy var mapView: BMKMapView = {
        let map = BMKMapView(frame: CGRect(x: 0, y: -1, width: UIScreen.width, height: mapContentViewHeight))
        map.showsUserLocation = true
        map.isBuildingsEnabled = false
        map.isScrollEnabled = true
        map.mapType = BMKMapType.standard
        map.zoomLevel = 13
        return map
    }()
    private var currentLocation: CLLocationCoordinate2D?
    private var routeSearch = BMKRouteSearch()
    
    private var detailVModel = OrderDetailVModel()
    private var model: OrderDetailModel?
    private var products: [ProductModel] = []

    private var contentHeight: CGFloat = 10
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
        _bindData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarShadowImageHidden = false
        mapView.delegate = self
        mapView.viewWillAppear()
        
        routeSearch.delegate = self
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.viewWillDisappear()
        mapView.delegate = nil
        
        routeSearch.delegate = nil
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: UIScreen.width, height: contentHeight)
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        // 导航
        var toCoordinate: CLLocationCoordinate2D?
        if let latitudeString = model?.addressInfo?.latitude, let longitudeString = model?.addressInfo?.longitude, let latitude = Double(latitudeString), let longitude = Double(longitudeString)  {
            toCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        guard let from = self.currentLocation, let to = toCoordinate else {
            return
        }
        let option = BMKOpenWalkingRouteOption()
        option.appScheme = "baidumapsdk://mapsdk.baidu.com"
        option.isSupportWeb = true
        
        let start = BMKPlanNode()
        start.pt = from
        start.name = "我的位置"
        option.startPoint = start
        let end = BMKPlanNode()
        end.pt = to
        end.name = "\(model?.addressInfo?.area ?? "")\(model?.addressInfo?.userAddress ?? "")"
        option.endPoint = end
        
        let ret = BMKOpenRoute.openBaiduMapWalkingRoute(option)
        if ret != BMK_OPEN_NO_ERROR {
            Toast.message("开启百度导航失败")
            print("导航    \(ret)")
        }
    }
    
}

extension DHomeDetailViewController {
    
    private func _initUI() {
        navigationItem.title = "订单详情"
        
        cornerView.round(byRoundingCorners: UIRectCorner(rawValue: UIRectCorner.topRight.rawValue | UIRectCorner.bottomRight.rawValue), cornerRadi: 5)
        
        tableView.register(UINib(nibName: "DHomeDetailTableViewCell", bundle: Bundle.currentDHome), forCellReuseIdentifier: NSStringFromClass(DHomeDetailTableViewCell.self))
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(_gestureAction(_:)))
        phoneView.addGestureRecognizer(gesture)
        
        mapContentHeightConstraint.constant = mapContentViewHeight
        mapContentView.addSubview(mapView)
    }
    
    @objc private func _gestureAction(_ gestureRecognizer: UIGestureRecognizer) {
        guard let addressInfo = self.model?.addressInfo, let url = URL(string: "telprompt://\(addressInfo.userPhone)") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func _bindData() {
        guard let model = self.model, let order = model.order, let addressInfo = model.addressInfo else { return }
        
        let deliveryStartTime = Date(timeIntervalSince1970: order.deliveryStartTime / 1000).format(to: "MM月dd日 HH:mm")
        let deliveryEndTime = Date(timeIntervalSince1970: order.deliveryEndTime / 1000).format(to: "HH:mm")
        timeLabel.text = "\(deliveryStartTime)-\(deliveryEndTime)"

        products = model.products ?? []
        tableView.reloadData()
        tableHeightConstraint.constant = CGFloat(products.count) * DHomeDetailTableViewCell.height + 1
        contentHeight += tableHeightConstraint.constant

        receiveLabel.text = addressInfo.userName
        SNoLabel.text = order.orderSNo
        contentHeight += 60
        
        addressLabel.text = "\(addressInfo.area ?? "")\(addressInfo.userAddress ?? "")"
        let addressHeight = addressLabel.text?.heightWith(font: addressLabel.font, limitWidth: UIScreen.width - 110) ?? 16
        contentHeight += 50
        
        contentHeight += 50

        contentHeight += mapContentViewHeight
        contentHeightConstraint.constant = contentHeight
    }
    
    // 移动地图视图到中间
    private func _updateMapStatus(_ location: CLLocationCoordinate2D) {
        let mapStatus = BMKMapStatus()
        mapStatus.targetGeoPt = location
        mapStatus.targetScreenPt = CGPoint(x: mapView.width / 2.0, y: mapView.height / 2.0)
        mapView.setMapStatus(mapStatus, withAnimation: true, withAnimationTime: 350)
    }
}

extension DHomeDetailViewController {
    
    static public func show(with model: OrderDetailModel) {
        let vc = DHomeDetailViewController(nibName: "DHomeDetailViewController", bundle: Bundle.currentDHome)
        vc.model = model
        vc.hidesBottomBarWhenPushed = true
        currentNavigationController?.pushViewController(vc, animated: true)
    }
    
}

extension DHomeDetailViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DHomeDetailTableViewCell.self)) as? DHomeDetailTableViewCell {
            cell.model = products[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }

}

extension DHomeDetailViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DHomeDetailTableViewCell.height
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        GoodsDetailViewController.show(with: products[indexPath.row].productId)
    }

}

extension DHomeDetailViewController: BMKMapViewDelegate {
    
    public func mapViewDidFinishLoading(_ mapView: BMKMapView!) {
        XLocationManager.default.startUpdatingLocation { [weak self] (info, error) in
            if let location = info?.location {
                self?.currentLocation = location.coordinate
                
                let fromAnnotation = BMKPointAnnotation()
                fromAnnotation.coordinate = location.coordinate
                mapView.addAnnotation(fromAnnotation)
                self?._updateMapStatus(location.coordinate)
                
                if let latitudeString = self?.model?.addressInfo?.latitude, let longitudeString = self?.model?.addressInfo?.longitude, let latitude = Double(latitudeString), let longitude = Double(longitudeString)  {
                    let toAnnotation = BMKPointAnnotation()
                    toAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    mapView.addAnnotation(toAnnotation)
                }
            }
        }
    }
    
    public func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if annotation is BMKPointAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "identifier")
            if annotationView == nil {
                annotationView = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: "identifier")
            }
            let widthHeight: CGFloat = 40
            annotationView?.centerOffset = CGPoint(x: widthHeight / 2.0, y: widthHeight)
            if annotation.coordinate.latitude == self.currentLocation?.latitude, annotation.coordinate.longitude == self.currentLocation?.longitude {
                annotationView?.image = UIImage(named: "icon_start", in: Bundle.currentDHome, compatibleWith: nil)?.scaleTo(fitSize: CGSize(width: widthHeight, height: widthHeight))
            } else {
                annotationView?.image = UIImage(named: "icon_end", in: Bundle.currentDHome, compatibleWith: nil)?.scaleTo(fitSize: CGSize(width: widthHeight, height: widthHeight))
            }
            return annotationView
        }
        return nil
    }
}

/// MARK:
extension DHomeDetailViewController: BMKRouteSearchDelegate {
    
    public func onGetRidingRouteResult(_ searcher: BMKRouteSearch!, result: BMKRidingRouteResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            
        }
    }
    
}
