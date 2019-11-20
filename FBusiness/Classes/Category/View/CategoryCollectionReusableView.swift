//
//  CategoryCollectionReusableView.swift
//  FBusiness
//
//

import UIKit

class CategoryCollectionReusableView: UICollectionReusableView {

    static let height: CGFloat = 28

    let promptLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor(hexColor: "#65B20C")
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(promptLabel)
        promptLabel.snp.makeConstraints {
            $0.leading.equalTo(10)
            $0.trailing.equalTo(-10)
            $0.centerY.equalTo(self.snp.centerY)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
