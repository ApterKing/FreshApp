//
//  GoodsTableHeaderView.swift
//  FBusiness
//
//

import UIKit

class GoodsTableHeaderView: UITableViewHeaderFooterView {

    static let height: CGFloat = UIScreen.width / 75 * 12

    let headerImgv: UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "bg_goods_header_prompt", in: Bundle.currentBase, compatibleWith: nil)
        imgv.contentMode = .scaleAspectFill
        return imgv
    }()

    private let promptLabel: UILabel = {
        let label = UILabel()
        label.text = "为保证水果品质最佳，水果将在每日 18:00-\(CityVModel.default.currentCity?.config?.orderDeadline ?? "21:00") 暂停销售，为您造成的不便我们深感抱歉"
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(headerImgv)
        headerImgv.snp.makeConstraints {
            $0.edges.equalTo(0)
        }

        contentView.addSubview(promptLabel)
        promptLabel.snp.makeConstraints {
            $0.leading.equalTo(UIScreen.width / 75 * 25)
            $0.trailing.equalTo(-10)
            $0.centerY.equalTo(contentView.snp.centerY)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
