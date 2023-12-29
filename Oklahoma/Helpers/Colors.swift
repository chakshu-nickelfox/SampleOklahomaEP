//
//  Colors.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import Foundation
import FLUtilities
import UIKit

struct Colors {
    static var primaryColor: UIColor {
        return UIColor(hexString: "F7C004")
    }
    
    static var disabledGrey: UIColor {
        return UIColor(hexString: "7B7979")
    }

    static var redColor: UIColor {
        return UIColor(hexString: "DD6551")
    }

    static var greenColor: UIColor {
        return UIColor(hexString: "60D07D")
    }
    
    static var secondaryDark: UIColor {
        return UIColor(hex: 0x636466)
    }
    
    static var primaryYellow: UIColor {
        return UIColor(hex: 0xF7C004)
    }
    static var primaryDark: UIColor {
        return UIColor.black
    }
  
    static var incorrectOptionColor: UIColor {
        return UIColor.init(hexString: "DD6551")
    }
    
    static var correctOptionColor: UIColor {
        return UIColor.init(hexString: "60D07D")
    }
    
    static var skippedOptionColor: UIColor {
        return UIColor.init(hexString: "F7C004")
    }
    
    static var offWhiteColor: UIColor {
        return UIColor.init(hexString: "FFFFFF").withAlphaComponent(0.9)
    }
    
    static var secondaryDarkColor: UIColor {
        return UIColor(hexString: "231F20")
    }
    static var primaryGreen: UIColor {
        return UIColor.init(hexString: "00BF5E")
    }
    
    static var primaryRed: UIColor {
        return UIColor.init(hexString: "DD6551")
    }
    
    static var mediumDark: UIColor {
        return UIColor.init(hexString: "434342")
    }
    
    static var secondaryLightGray: UIColor {
        return UIColor.init(hexString: "4F4C4D")
    }
    
    static var BDBDBD: UIColor {
        return UIColor.init(hexString: "BDBDBD")
    }
    
    static var primaryGray: UIColor {
        return UIColor.init(hexString: "434342")
    }
}
