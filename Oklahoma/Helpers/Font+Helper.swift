//
//  Font+Helper.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import Foundation
import UIKit

extension UILabel {
    func setFont(_ fontType: FontType) {
        self.font = AppFont.getFont(fontType: fontType)
    }
    
    func setLabelBorder() {
        self.layer.cornerRadius = 10
    }
    
}

extension UIButton {
    func setFont(_ fontType: FontType) {
        self.titleLabel?.font = AppFont.getFont(fontType: fontType)
    }
    func setButtonBorder() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        self.layer.borderColor = #colorLiteral(red: 0.6901960784, green: 0.7882352941, blue: 0.9019607843, alpha: 0.8470588235)
    }
    
    func setButtonBorderMap() {
        self.layer.cornerRadius = 20
    }
    func setButtonCornerRounded() {
        self.layer.cornerRadius = 5
        
    }
    
    func setButtonColor() {
        self.layer.cornerRadius = 20
    }
}


extension UITextField {
    func setFont(_ fontType: FontType) {
        self.font = AppFont.getFont(fontType: fontType)
    }
}

extension UITextView {
    func setFont(_ fontType: FontType) {
        self.font = AppFont.getFont(fontType: fontType)
    }
}


extension UIView {
    func setViewBorder() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = 8
        self.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.layer.borderWidth = 1
    }
    
    func setDesignStatusBorder() {
        self.layer.cornerRadius = 10
    }
    
    func setWindowBorder() {
        self.layer.cornerRadius = 5
        
        func roundCorners(corners: UIRectCorner, radius: CGFloat) {
            DispatchQueue.main.async {
                let path = UIBezierPath(roundedRect: self.bounds,
                                        byRoundingCorners: corners,
                                        cornerRadii: CGSize(width: radius, height: radius))
                let maskLayer = CAShapeLayer()
                maskLayer.frame = self.bounds
                maskLayer.path = path.cgPath
                self.layer.mask = maskLayer
            }
        }
    }
    
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        
        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = self.bounds
            maskLayer.path = path.cgPath
            self.layer.mask = maskLayer
        }
    }
    
}

extension UIImageView {
    
    func roundCorner() {
        self.layer.cornerRadius = 5
    }
}

extension UIFont {
  
    class func poppinsRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Regular", size: size)!
    }
    
    class func poppinsMedium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Medium", size: size)!
    }
    
    class func poppinsBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-SemiBold", size: size)!
    }
    
    class func avenirNextMedium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Medium", size: size)!
    }
    
    class func poppinsBlack(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Black", size: size)!
    }
    
    class func poppinsSemiBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-SemiBold", size: size) ?? UIFont()
    }
    
    class func poppinsThin(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Thin", size: size)!
    }
}

enum FontType {
    
    case s12, s14, s16, p6, p14, p16, p18, h12, h14, h16, h18, h1, h2, p1, p2, p3, p4, p5,h3, p7, p8, m1, m2, m3, m4, m6, m7, m8, m9, m10
    
    var name: String {
        switch self {
        case .p18, .p16:
            return "Poppins-Regular"
        case .s16, .s14, .s12:
            return "Poppins-SemiBold"
        case .p14, .p6:
            return "Lato-Regular"
        case .h12:
            return "Lato-Medium"
        case .h16, .h14:
            return "Lato-Bold"
        case .h18:
            return "Helvetica Neue Bold"
        case .h1, .h2, .h3, .p7, .p8:
            return "Poppins-SemiBold"
        case .p1, .p2, .p3, .p4, .p5:
            return "Poppins-Regular"
        case .m1, .m4, .m6, .m8, .m9 , .m10:
            return "Lato-Bold"
        case .m2:
            return "Helvetica Neue Bold"
        case .m3, .m7:
            return "Lato-Regular"
        }
    }
    
    var fontSizeIPhone: CGFloat {
        switch self {
        case .p6:
            return 6
        case .s12, .h12:
            return 12
        case .s14, .p14, .h14:
            return 14
        case .s16, .p16, .h16:
            return 16
        case .p18, .h18:
            return 18
        case .h1:
            return 16
        case .h2, .p3:
            return 12
        case .p2, .h3:
            return 14
        case .p1:
            return 16
        case .p4:
            return 18
        case .p5:
            return 16
        case .p7:
            return 12
        case .p8:
            return 14
        case .m1:
            return 24
        case  .m2:
            return 18
        case .m3, .m10:
            return 14
        case .m4:
            return 16
        case .m6:
            return 18
        case .m7:
            return 6
        case .m8:
            return 14
        case .m9:
            return 26
        }
    }
    
    var fontSizeIPad: CGFloat {
        switch self {
        case .p6:
            return 8
        case .s12, .h12:
            return 14
        case .s14, .p14, .h14:
            return 16
        case .s16, .p16, .h16:
            return 18
        case .p18, .h18:
            return 20
        case .h1:
            return 20
        case .h2, .p3:
            return 18
        case .p2, .h3:
            return 18
        case .p1:
            return 16
        case .p4:
            return 18
        case .p5:
            return 20
        case .p7:
            return 14
        case .p8:
            return 16
        case .m1:
            return 26
        case .m2:
            return 20
        case .m3, .m10:
            return 16
        case .m4:
            return 18
        case .m6:
            return 20
        case .m7:
            return 8
        case .m8:
            return 16
        case .m9:
            return 26
        }
    }
}

struct AppFont {
    
    private static func getFontInternal(name: String,
                                        iPhoneSize: CGFloat,
                                        iPadSize: CGFloat) -> UIFont {
        let defaultFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return UIFont(name: name, size: iPadSize) ?? defaultFont
        default:
            return UIFont(name: name, size: iPhoneSize) ?? defaultFont
        }
    }
    
    static func getFont(fontType: FontType) -> UIFont {
        AppFont.getFontInternal(name: fontType.name,
                                iPhoneSize: fontType.fontSizeIPhone,
                                iPadSize: fontType.fontSizeIPhone)
    }
    
}
