//
//  UIDevice+Helper.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import Foundation
import UIKit

extension UIDevice {
    
    static var isIPad:Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// Returns `true` if the device has a notch
    var hasNotch: Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
        if UIWindow.isLandscape {
         return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        } else {
         return window.safeAreaInsets.top >= 44
        }
    }
    
}

extension UIWindow {
    static var isLandscape: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
}
