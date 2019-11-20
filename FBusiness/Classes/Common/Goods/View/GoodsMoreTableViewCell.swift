//
//  GoodsMoreTableViewCell.swift
//  FBusiness
//
//

import UIKit

class GoodsMoreTableViewCell: UITableViewCell {

    static let height: CGFloat = UIScreen.width / 75 * 16

    let moreImgv: UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "bg_more_goods", in: Bundle.currentBase, compatibleWith: nil)
        imgv.contentMode = .scaleAspectFill
        return imgv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(moreImgv)
        moreImgv.snp.makeConstraints {
            $0.edges.equalTo(0)
        }

        selectionStyle = .none
        isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
