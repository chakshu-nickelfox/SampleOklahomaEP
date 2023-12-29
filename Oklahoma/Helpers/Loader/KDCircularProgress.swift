//
//  KDCircularProgress.swift
//  LifeSafetyEducator4
//
//  Created by Akanksha Trivedi on 19/09/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import Foundation
import UIKit

public enum KDCircularProgressGlowMode {
    case forward, reverse, constant, noGlow
}

open class KDCircularProgress: UIView, CAAnimationDelegate {
    
    struct Conversion {
        static func degreesToRadians (_ value: CGFloat) -> CGFloat {
            return value * CGFloat(Double.pi) / 180.0
        }
        
        static func radiansToDegrees (_ value: CGFloat) -> CGFloat {
            return value * 180.0 / CGFloat(Double.pi)
        }
    }
    
    struct Utility {
        static func clamp<T: Comparable>(_ value: T, minMax: (T, T)) -> T {
            let (min, max) = minMax
            if value < min {
                return min
            } else if value > max {
                return max
            } else {
                return value
            }
        }
        
        static func inverseLerp(_ value: CGFloat, minMax: (CGFloat, CGFloat)) -> CGFloat {
            return (value - minMax.0) / (minMax.1 - minMax.0)
        }
        
        static func lerp(_ value: CGFloat, minMax: (CGFloat, CGFloat)) -> CGFloat {
            return (minMax.1 - minMax.0) * value + minMax.0
        }
        
        static func colorLerp(_ value: CGFloat, minMax: (UIColor, UIColor)) -> UIColor {
            let clampedValue = clamp(value, minMax: (0, 1))
            
            let zero: CGFloat = 0
            
            var (r0, g0, b0, a0) = (zero, zero, zero, zero)
            minMax.0.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
            
            var (r1, g1, b1, a1) = (zero, zero, zero, zero)
            minMax.1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            
            return UIColor(red: lerp(clampedValue, minMax: (r0, r1)),
                           green: lerp(clampedValue, minMax: (g0, g1)),
                           blue: lerp(clampedValue, minMax: (b0, b1)),
                           alpha: lerp(clampedValue, minMax: (a0, a1)))
        }
        
        static func mod(_ value: Double, range: Double, minMax: (Double, Double)) -> Double {
            let (min, max) = minMax
            assert(abs(range) <= abs(max - min), "range should be <= than the interval")
            if value >= min && value <= max {
                return value
            } else if value < min {
                return mod(value + range, range: range, minMax: minMax)
            } else {
                return mod(value - range, range: range, minMax: minMax)
            }
        }
    }
    
    fileprivate var progressLayer: KDCircularProgressViewLayer {
        return layer as? KDCircularProgressViewLayer ?? KDCircularProgressViewLayer()
    }
    
    fileprivate var radius: CGFloat! {
        didSet {
            progressLayer.radius = radius
        }
    }
    
    open var angle: Double = 0 {
        didSet {
            if self.isAnimating() {
                self.pauseAnimation()
            }
            progressLayer.angle = angle
        }
    }
    
    open var startAngle: Double = 0 {
        didSet {
            startAngle = Utility.mod(startAngle, range: 360, minMax: (0, 360))
            progressLayer.startAngle = startAngle
            progressLayer.setNeedsDisplay()
        }
    }
    
    open var clockwise: Bool = true {
        didSet {
            progressLayer.clockwise = clockwise
            progressLayer.setNeedsDisplay()
        }
    }
    
    open var roundedCorners: Bool = true {
        didSet {
            progressLayer.roundedCorners = roundedCorners
        }
    }
    
     open var lerpColorMode: Bool = false {
        didSet {
            progressLayer.lerpColorMode = lerpColorMode
        }
    }
    
    open var gradientRotateSpeed: CGFloat = 0 {
        didSet {
            progressLayer.gradientRotateSpeed = gradientRotateSpeed
        }
    }
    
    open var glowAmount: CGFloat = 1.0 {
        didSet {
            glowAmount = Utility.clamp(glowAmount, minMax: (0, 1))
            progressLayer.glowAmount = glowAmount
        }
    }
    
    // SWIFT 4 ERROR
    // @IBInspectable open var glowMode: KDCircularProgressGlowMode = .forward {
    @nonobjc open var glowMode: KDCircularProgressGlowMode = .forward {
        didSet {
            progressLayer.glowMode = glowMode
        }
    }
    
    open var progressThickness: CGFloat = 0.4 {
        didSet {
            progressThickness = Utility.clamp(progressThickness, minMax: (0, 1))
            progressLayer.progressThickness = progressThickness/2
        }
    }
    
    open var trackThickness: CGFloat = 0.5 {
        didSet {
            trackThickness = Utility.clamp(trackThickness, minMax: (0, 1))
            progressLayer.trackThickness = trackThickness/2
        }
    }
    
    open var trackColor: UIColor = .black {
        didSet {
            progressLayer.trackColor = trackColor
            progressLayer.setNeedsDisplay()
        }
    }
    
    open var progressInsideFillColor: UIColor? {
        didSet {
            if let color = progressInsideFillColor {
                progressLayer.progressInsideFillColor = color
            } else {
                progressLayer.progressInsideFillColor = .clear
            }
        }
    }
    
    open var progressColors: [UIColor]! {
        get {
            return progressLayer.colorsArray
        }

        set(newValue) {
            setColors(newValue)
        }
    }
    
    // These are used only from the Interface-Builder. Changing these from code will have no effect.
    // Also IB colors are limited to 3, whereas programatically we can have an arbitrary number of them.
    @IBInspectable fileprivate var IBColor1: UIColor?
    @IBInspectable fileprivate var IBColor2: UIColor?
    @IBInspectable fileprivate var IBColor3: UIColor?
    
    fileprivate var animationCompletionBlock: ((Bool) -> Void)?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        setInitialValues()
        refreshValues()
        checkAndSetIBColors()
    }
    
    convenience public init(frame: CGRect, colors: UIColor...) {
        self.init(frame: frame)
        setColors(colors)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        setInitialValues()
        refreshValues()
    }
    
    open override func awakeFromNib() {
        checkAndSetIBColors()
    }
    
    override open class var layerClass: AnyClass {
        return KDCircularProgressViewLayer.self
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        radius = (frame.size.width/2.0) * 0.8
    }
    
    fileprivate func setInitialValues() {
        radius = (frame.size.width/2.0) * 0.8 // We always apply a 20% padding, stopping glows from being clipped
        backgroundColor = .clear
        setColors(.white, .cyan)
    }
    
    fileprivate func refreshValues() {
        progressLayer.angle = angle
        progressLayer.startAngle = startAngle
        progressLayer.clockwise = clockwise
        progressLayer.roundedCorners = roundedCorners
        progressLayer.lerpColorMode = lerpColorMode
        progressLayer.gradientRotateSpeed = gradientRotateSpeed
        progressLayer.glowAmount = glowAmount
        progressLayer.glowMode = glowMode
        progressLayer.progressThickness = progressThickness/2
        progressLayer.trackColor = trackColor
        progressLayer.trackThickness = trackThickness/2
    }
    
    fileprivate func checkAndSetIBColors() {
        let nonNilColors = [IBColor1, IBColor2, IBColor3].compactMap { $0 }
        if !nonNilColors.isEmpty {
            setColors(nonNilColors)
        }
    }
    
    open func setColors(_ colors: UIColor...) {
        setColors(colors)
    }
    
    fileprivate func setColors(_ colors: [UIColor]) {
        progressLayer.colorsArray = colors
        progressLayer.setNeedsDisplay()
    }
    
    @objc open func animateFromAngle(_ fromAngle: Double, toAngle: Double, duration: TimeInterval, relativeDuration: Bool = true, completion: ((Bool) -> Void)?) {
        if isAnimating() {
            pauseAnimation()
        }
        
        let animationDuration: TimeInterval
        if relativeDuration {
            animationDuration = duration
        } else {
            let traveledAngle = Utility.mod(toAngle - fromAngle, range: 360, minMax: (0, 360))
            let scaledDuration = (TimeInterval(traveledAngle) * duration) / 360
            animationDuration = scaledDuration
        }
        
        let animation = CABasicAnimation(keyPath: "angle")
        animation.fromValue = fromAngle
        animation.toValue = toAngle
        animation.duration = animationDuration
        animation.delegate = self
        angle = toAngle
        animationCompletionBlock = completion
        
        progressLayer.add(animation, forKey: "angle")
    }
    
    @objc open func animateToAngle(_ toAngle: Double, duration: TimeInterval, relativeDuration: Bool = true, completion: ((Bool) -> Void)?) {
        if isAnimating() {
            pauseAnimation()
        }
        animateFromAngle(angle, toAngle: toAngle, duration: duration, relativeDuration: relativeDuration, completion: completion)
    }
    
    @objc open func pauseAnimation() {
        guard let presentationLayer = progressLayer.presentation() else { return }
        let currentValue = presentationLayer.angle
        progressLayer.removeAllAnimations()
        animationCompletionBlock = nil
        angle = currentValue
    }
    
    @objc open func stopAnimation() {
        animationCompletionBlock = nil
        progressLayer.removeAllAnimations()
        angle = 0
    }
    
    @objc open func isAnimating() -> Bool {
        return progressLayer.animation(forKey: "angle") != nil
    }
    
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let completionBlock = animationCompletionBlock {
            if flag {
                animationCompletionBlock = nil
            }
            
            completionBlock(flag)
        }
    }
    
    open override func didMoveToWindow() {
        if let window = window {
            progressLayer.contentsScale = window.screen.scale
        }
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil && isAnimating() {
            pauseAnimation()
        }
    }
    
    open override func prepareForInterfaceBuilder() {
        setInitialValues()
        refreshValues()
        checkAndSetIBColors()
        progressLayer.setNeedsDisplay()
    }
}
