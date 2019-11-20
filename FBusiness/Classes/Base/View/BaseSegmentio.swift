//
//  BaseSegmentio.swift
//  FBusiness
//
//

import UIKit
import Segmentio

public class BaseSegmentio: UIView {
    
    static let height: CGFloat = 44

    var selectedIndex: Int = 0 {
        didSet {
            segmentioView.selectedSegmentioIndex = selectedIndex
        }
    }
    var valueDidChange: SegmentioSelectionCallback? {
        didSet {
            segmentioView.valueDidChange = valueDidChange
        }
    }
    
    private lazy var segmentioView: Segmentio = {
        let view = Segmentio(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: BaseSegmentio.height))
        return view
    }()
    private var segmentioItems: [SegmentioItem] = []
    private var segmentPosition: SegmentioPosition = .dynamic
    private var ratio: CGFloat = 0.65
    private var showBottomLine = false
    convenience init(_ titles: [String], _ segmentPosition: SegmentioPosition = .dynamic, _ ratio: CGFloat = 0.65, _ showBottomLine: Bool = false) {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: BaseSegmentio.height))
        self.ratio = ratio
        self.showBottomLine = showBottomLine
        segmentioItems = titles.map({ (title) -> SegmentioItem in
            return SegmentioItem(title: title, image: nil)
        })
        self.segmentPosition = segmentPosition
        _initUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        segmentioView.frame = bounds
    }
}

extension BaseSegmentio {
    private func _initUI() {
        let states = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.systemFont(ofSize: 15),
                titleTextColor: UIColor(hexColor: "#282536")
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.systemFont(ofSize: 15),
                titleTextColor: UIColor(hexColor: "#66B30C")
            ),
            highlightedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.boldSystemFont(ofSize: 15),
                titleTextColor: UIColor(hexColor: "#66B30C")
            )
        )
        let indicationOptions = SegmentioIndicatorOptions(type: SegmentioIndicatorType.bottom, ratio: ratio, height: 2.5, color: UIColor(hexColor: "#66B30C"))
        let options = SegmentioOptions(backgroundColor: .white,
                                       segmentPosition: segmentPosition,
                                       scrollEnabled: true,
                                       indicatorOptions: indicationOptions,
                                       horizontalSeparatorOptions: nil,
                                       verticalSeparatorOptions: nil,
                                       imageContentMode: .bottom,
                                       labelTextAlignment: .center,
                                       labelTextNumberOfLines: 1,
                                       segmentStates: states,
                                       animationDuration: 0.25
        )
        segmentioView.selectedSegmentioIndex = 0
        segmentioView.setup(content: segmentioItems, style: SegmentioStyle.imageOverLabel, options: options)
        
        if showBottomLine {
            let view = UIView(frame: CGRect(x: 0, y: segmentioView.height - 1.25, width: segmentioView.width, height: 1))
            view.backgroundColor = UIColor(hexColor: "#f7f7f7")
            segmentioView.layer.insertSublayer(view.layer, at: 1)
        }
        addSubview(segmentioView)
    }
}
