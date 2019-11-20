//
//  CitySelectedViewController.swift
//  FBusiness
//
//

import UIKit
import SwiftX

public class CitySelectedViewController: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .plain)
        tv.separatorStyle = .none
        tv.backgroundColor = UIColor(hexColor: "#f7f7f7")
        tv.register(CityTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(CityTableViewCell.self))
        tv.register(CitySectionHeader.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(CitySectionHeader.self))
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
    }

}

extension CitySelectedViewController {
    
    private func _initUI() {
        navigationItem.title = "选择城市"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(0)
        }
    }
}

extension CitySelectedViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : CityVModel.default.datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CityTableViewCell.self)) as? CityTableViewCell {
            if indexPath.section == 0 {
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = false
                cell.nameLabel.textColor = UIColor(hexColor: "#66B30C")
                cell.nameLabel.text = CityVModel.default.currentCityName
            } else {
                let model = CityVModel.default.datas[indexPath.row]
                cell.selectionStyle = .default
                cell.nameLabel.textColor = UIColor(hexColor: "#666666")
                cell.nameLabel.text = model.cityName
            }
            return cell
        }
        return UITableViewCell()
    }
    
}

extension CitySelectedViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CityTableViewCell.height
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CitySectionHeader.height
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(CitySectionHeader.self)) as? CitySectionHeader {
            header.promptLabel.text = section == 0 ? "当前选择：" : "所有开通城市："
            return header
        }
        return CitySectionHeader()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section != 0 {
            CityVModel.default.currentCity = CityVModel.default.datas[indexPath.row]
            topNavigationController?.popViewController(animated: true)
        }
    }

}

extension CitySelectedViewController {

    class CitySectionHeader: UITableViewHeaderFooterView {
        
        static let height: CGFloat = 35
        
        lazy var promptLabel: UILabel = {
            let label = UILabel(frame: CGRect.zero)
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(hexColor: "#333333")
            return label
        }()
        
        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            contentView.backgroundColor = UIColor(hexColor: "#f7f7f7")
            contentView.addSubview(promptLabel)
            promptLabel.snp.makeConstraints {
                $0.left.equalTo(15)
                $0.centerY.equalTo(contentView.snp.centerY)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    class CityTableViewCell: BaseTableViewCell {
        
        static let height: CGFloat = 50
        
        lazy var nameLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = UIColor(hexColor: "#333333")
            return label
        }()
        
        lazy var separatorLine: UIView = {
            let view = UIView(frame: CGRect.zero)
            view.backgroundColor = UIColor(hexColor: "#f7f7f7")
            return view
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.backgroundColor = UIColor.white
            contentView.addSubview(nameLabel)
            nameLabel.snp.makeConstraints {
                $0.left.equalTo(15)
                $0.centerY.equalTo(contentView.snp.centerY)
            }
            
            contentView.addSubview(separatorLine)
            separatorLine.snp.makeConstraints {
                $0.left.equalTo(15)
                $0.bottom.equalTo(0)
                $0.right.equalTo(-15)
                $0.height.equalTo(1)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
