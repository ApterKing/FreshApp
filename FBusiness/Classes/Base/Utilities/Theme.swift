//
//  Theme.swift
//  FBusiness
//
//

import UIKit

public class Theme: NSObject {
    
    static func decorate(button: UIButton, font: UIFont = UIFont.systemFont(ofSize: 18), color: UIColor? = UIColor(hexColor: "#66B30C"), cornerRadius: CGFloat = 5) {
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = font
        button.setTitleColor(UIColor.white, for: .normal)
        button.setBackgroundImage(UIImage(color: UIColor(hexColor: "#C2CBC7")), for: .disabled)
        button.setBackgroundImage(UIImage(color: color ?? UIColor.white), for: .normal)
        button.setBackgroundImage(UIImage(color: color?.withAlphaComponent(0.9) ?? UIColor.white), for: .highlighted)
        button.layer.cornerRadius = cornerRadius
        button.clipsToBounds = true
    }
    
    static func decorate(field: UITextField, shadowColor: UIColor?, borderColor: UIColor) {
        field.layer.cornerRadius = field.height / 2.0
        field.layer.borderColor = borderColor.cgColor
        field.layer.borderWidth = 1
        
        field.layer.shadowColor = shadowColor?.cgColor
        field.layer.shadowRadius = 2
        field.layer.shadowOpacity = 0.7
        field.layer.shadowOffset = CGSize(width: 0, height: 1)
        field.layer.shadowPath = UIBezierPath(roundedRect: field.bounds, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: field.height / 2.0, height: field.height / 2.0)).cgPath
    }

}
