//
//  Storyboard.swift
//  LifeSafetyEducator4
//
//  Created by Ravindra Soni on 11/12/18.
//  Copyright © 2018 Nickelfox. All rights reserved.
//


import UIKit
import FLUtilities

enum Storyboard: String {
    
    case home = "Home"
    case audiobooks = "AudioBooks"
    case examPrep = "ExamPrep"
    case menuSheet = "MenuSheet"
    case inAppPurchase = "InAppPurchase"
    case video = "Video"
    
    var name: String {
        return self.rawValue
    }
    
}

extension UIViewController {
    
    static var storyboardId: String {
        return self.className()
    }
    
}
