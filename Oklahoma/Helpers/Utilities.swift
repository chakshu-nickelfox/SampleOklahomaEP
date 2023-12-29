//
//  Utilities.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import Foundation
import UIKit

class Utilities {
    // MARK: - Activity Indicator
    
    func setUpActivityIndicator(_ frameWidth: CGFloat, frameHeight: CGFloat ) -> UIActivityIndicatorView {
        
        let screenwidth = frameWidth/2
        let screenheight = frameHeight/2
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect(x: screenwidth - 15, y: screenheight - 15, width: 30, height: 30)
        
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicator.transform = transform
        
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }
    
    
    func showActivityIndicator(_ activityIndicator: UIActivityIndicatorView) {
        // self.activityIndicatorHolderView.hidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
    }
    
    
    func hideActivityIndicator(_ activityIndicator: UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
        if(UIApplication.shared.isIgnoringInteractionEvents == true) {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        // self.activityIndicatorHolderView.hidden = true
        activityIndicator.isHidden = true
    }

    static func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
