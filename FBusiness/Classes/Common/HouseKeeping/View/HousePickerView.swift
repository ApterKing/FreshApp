//
//  HousePickerView.swift
//  FBusiness
//
//

import UIKit
import SwiftX

public class HousePickerView: UIView {
    
    public typealias ComplectionHandler = ((_ value: Date) -> Void)
    
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerBottomView: NSLayoutConstraint!
    
    private lazy var formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM-dd EEE"
        df.shortWeekdaySymbols = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        df.locale = Locale(identifier: "zh_CN")
        return df
    }()
    private let todayDate: Date = {
        var date = Date()
        let timestamp = date.hour * 3600 + date.minute * 60 + date.second
        date.addTimeInterval(TimeInterval(-timestamp))
        return date
    }()
    
    private let contentViewHeight: CGFloat = UIDevice.isIphone4_5() ? 280 : 300
    public var handler: ComplectionHandler?

    class func loadFromXib() -> HousePickerView {
        
        if let view = Bundle.currentCommon.loadNibNamed("HousePickerView", owner: self, options: nil)?.first as? HousePickerView {
            view.frame = UIScreen.main.bounds
            view.contentBottomConstraint.constant = 0
            return view
        }
        return HousePickerView()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        opacityView.alpha = 0.01
        
        contentHeightConstraint.constant = contentViewHeight
        contentBottomConstraint.constant = -contentViewHeight
    }
    

    @IBAction func buttonAction(_ sender: UIButton) {
        _dismiss()
        if sender.tag == 1 {
            let row0 = pickerView.selectedRow(inComponent: 0)
            let row1 = pickerView.selectedRow(inComponent: 1)
            let row2 = pickerView.selectedRow(inComponent: 2)
            var date = todayDate.adding(Calendar.Component.day, value: row0)
            date = date.adding(Calendar.Component.hour, value: row1)
            date = date.adding(Calendar.Component.minute, value: row2)
            handler?(date)
        }
    }
}

extension HousePickerView {
    
    private func _show() {
        self.frame = topViewController?.view.bounds ?? UIScreen.main.bounds
        topViewController?.view.addSubview(self)
        opacityView.alpha = 0.01
        contentBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.opacityView.alpha = 0.7
        }) { (_) in
        }
    }
    
    private func _dismiss() {
        contentBottomConstraint.constant = -contentViewHeight
        UIView.animate(withDuration: 0.25, animations: {
            self.opacityView.alpha = 0.01
            self.layoutIfNeeded()
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
}

extension HousePickerView {
    func show(with date: Date) {
        pickerView.selectRow(date.day - todayDate.day, inComponent: 0, animated: true)
        pickerView.selectRow(date.hour, inComponent: 1, animated: true)
        pickerView.selectRow(date.minute, inComponent: 2, animated: true)
        _show()
    }
    
    func dismiss() {
        _dismiss()
    }
}

extension HousePickerView: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 365
        case 1:
            return 24
        default:
            return 60
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 40))
        label.textAlignment = .center
        label.width = width / 3.0
        label.font = UIFont.systemFont(ofSize: 17)
        
        switch component {
        case 0:
            label.text = formatter.string(from: todayDate.adding(Calendar.Component.day, value: row))
        case 1:
            label.text = String(format: "%2d 时", row)
        default:
            label.text = String(format: "%2d 分", row)
        }
        return label
    }
}

extension HousePickerView: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return width * 2 / 5
        } else {
            return width * 3 / 5 / 2
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
}

