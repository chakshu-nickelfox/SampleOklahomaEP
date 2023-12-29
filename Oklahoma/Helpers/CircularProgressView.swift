//
//  CircularProgressView.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import Foundation
import UIKit

class CircularProgressView: UIView {
    var progressLyr = CAShapeLayer()
    var trackLyr = CAShapeLayer()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeCircularPath()
    }
    var progressClr = UIColor.white {
        didSet {
            progressLyr.strokeColor = progressClr.cgColor
        }
    }
    var trackClr = UIColor.white {
        didSet {
            trackLyr.strokeColor = trackClr.cgColor
        }
    }
    func makeCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2
        let radius : CGFloat = 12 //radius of the circular ring
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2,
                                                         y: frame.size.height/2), radius: radius,
                                      startAngle: CGFloat(-0.5 * .pi),
                                      endAngle: CGFloat(1.5 * .pi),
                                      clockwise: true)
        trackLyr.path = circlePath.cgPath
        trackLyr.fillColor = UIColor.clear.cgColor
        trackLyr.strokeColor = trackClr.cgColor
        trackLyr.lineWidth = 3.0
        trackLyr.strokeEnd = 3.0
        layer.addSublayer(trackLyr)
        progressLyr.path = circlePath.cgPath
        progressLyr.fillColor = UIColor.clear.cgColor
        progressLyr.strokeColor = progressClr.cgColor
        progressLyr.lineWidth = 3.0
        progressLyr.strokeEnd = 0.0
        layer.addSublayer(progressLyr)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = value
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLyr.strokeEnd = CGFloat(value)
        progressLyr.add(animation, forKey: "animateprogress")
        
    }
}

class BounceButton: UIButton {
    var isLiked = false
    
    var reaction: MediaAction? = .bookmark
    
    private var unselectedImage: UIImage {
        UIImage(named: reaction?.unselectedImage ?? "") ?? UIImage()
    }
    private var selectedImage: UIImage {
        UIImage(named: reaction?.selectedImage ?? "") ?? UIImage()
    }
    
    private let unselectedScale: CGFloat = 0.8
    private let selectedScale: CGFloat = 1.2
    
    public func flipLikedState() {
        self.flipWithAnimation()
    }
    
    public func flipWithoutAnimation() {
        let newImage = self.isLiked ? self.selectedImage : self.unselectedImage
        self.setImage(newImage, for: .normal)
    }
    
    private func flipWithAnimation() {
        UIView.animate(withDuration: 0.17, animations: {
            let newImage = self.isLiked ? self.selectedImage : self.unselectedImage
            let newScale = self.isLiked ? self.selectedScale : self.unselectedScale
            self.transform = self.transform.scaledBy(x: newScale, y: newScale)
            self.setImage(newImage, for: .normal)
        }, completion: { _ in
            UIView.animate(withDuration: 0.17, animations: {
                self.transform = CGAffineTransform.identity
            })
        })
    }
}
