//
//  KDCircularProgress+Extension.swift
//  LifeSafetyEducator4
//
//  Created by Akanksha Trivedi on 11/09/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import Foundation
import UIKit

extension KDCircularProgress {
    
    class KDCircularProgressViewLayer: CALayer {
        @NSManaged var angle: Double
        var radius: CGFloat! {
            didSet {
                invalidateGradientCache()
            }
        }
        var startAngle: Double!
        var clockwise: Bool! {
            didSet {
                if clockwise != oldValue {
                    invalidateGradientCache()
                }
            }
        }
        var roundedCorners: Bool!
        var lerpColorMode: Bool!
        var gradientRotateSpeed: CGFloat! {
            didSet {
                invalidateGradientCache()
            }
        }
        var glowAmount: CGFloat!
        var glowMode: KDCircularProgressGlowMode!
        var progressThickness: CGFloat!
        var trackThickness: CGFloat!
        @objc var trackColor: UIColor!
        @objc var progressInsideFillColor: UIColor = UIColor.clear
        @objc var colorsArray: [UIColor]! {
            didSet {
                invalidateGradientCache()
            }
        }
        fileprivate var gradientCache: CGGradient?
        fileprivate var locationsCache: [CGFloat]?
        
        override class func needsDisplay(forKey key: String) -> Bool {
            return key == "angle" ? true : super.needsDisplay(forKey: key)
        }
        
        override init(layer: Any) {
            super.init(layer: layer)
            guard let progressLayer = layer as? KDCircularProgressViewLayer else { return }
            radius = progressLayer.radius
            angle = progressLayer.angle
            startAngle = progressLayer.startAngle
            clockwise = progressLayer.clockwise
            roundedCorners = progressLayer.roundedCorners
            lerpColorMode = progressLayer.lerpColorMode
            gradientRotateSpeed = progressLayer.gradientRotateSpeed
            glowAmount = progressLayer.glowAmount
            glowMode = progressLayer.glowMode
            progressThickness = progressLayer.progressThickness
            trackThickness = progressLayer.trackThickness
            trackColor = progressLayer.trackColor
            colorsArray = progressLayer.colorsArray
            progressInsideFillColor = progressLayer.progressInsideFillColor
        }
        
        override init() {
            super.init()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        fileprivate func extractDimensions(_ dimensions: ExtractedDimensions) {
            if let imageCtx = UIGraphicsGetCurrentContext() {
                let fromAngle = Conversion.degreesToRadians(CGFloat(-startAngle))
                let toAngle = Conversion.degreesToRadians(
                    CGFloat((clockwise == true ? -dimensions.reducedAngle : dimensions.reducedAngle) - startAngle)
                )
                
                let imageCenter = CGPoint(x: dimensions.width/2,
                                          y: dimensions.height/2)
                imageCtx.addArc(center: imageCenter,
                                radius: dimensions.arcRadius,
                                startAngle: fromAngle,
                                endAngle: toAngle,
                                clockwise: true)
                
                let glowValue = GlowConstants.glowAmountForAngle(
                    dimensions.reducedAngle,
                    glowAmount: glowAmount,
                    glowMode: glowMode,
                    size: dimensions.width
                )
                
                if glowValue > 0 {
                    imageCtx.setShadow(offset: CGSize.zero,
                                       blur: glowValue,
                                       color: UIColor.black.cgColor)
                }
                imageCtx.setLineCap(roundedCorners == true ? .round : .butt)
                imageCtx.setLineWidth(dimensions.progressLineWidth)
                imageCtx.drawPath(using: .stroke)
                
                guard let currentGraphicsContext = UIGraphicsGetCurrentContext() else {
                    return
                }
                
                if let drawMask: CGImage = currentGraphicsContext.makeImage() {
                    UIGraphicsEndImageContext()
                    dimensions.ctx.saveGState()
                    dimensions.ctx.clip(to: bounds, mask: drawMask)
                } else {
                    UIGraphicsEndImageContext()
                }
            }
        }
        
        override func draw(in ctx: CGContext) {
            UIGraphicsPushContext(ctx)
            
            let size = bounds.size
            let width = size.width
            let height = size.height
            
            let trackLineWidth = radius * trackThickness
            let progressLineWidth = radius * progressThickness
            let arcRadius = max(radius - trackLineWidth/2, radius - progressLineWidth/2)
            // CGContextAddArc(ctx, width/2.0, height/2.0, arcRadius, 0, CGFloat(M_PI * 2), 0)
            let center = CGPoint(x: width/2, y: height/2)
            ctx.addArc(center: center, radius: arcRadius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: false)
            trackColor.set()
            ctx.setStrokeColor(trackColor.cgColor)
            ctx.setFillColor(progressInsideFillColor.cgColor)
            ctx.setLineWidth(trackLineWidth)
            ctx.setLineCap(CGLineCap.butt)
            ctx.drawPath(using: .fillStroke)
            
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            let reducedAngle = Utility.mod(angle, range: 360, minMax: (0, 360))
            self.extractDimensions(ExtractedDimensions(reducedAngle: reducedAngle,
                                                       width: width,
                                                       height: height,
                                                       arcRadius: arcRadius,
                                                       progressLineWidth: progressLineWidth,
                                                       ctx: ctx))
            
            // Gradient - Fill
            if !lerpColorMode && colorsArray.count > 1 {
                let rgbColorsArray: [UIColor] = colorsArray.map { color in // Make sure every color in colors array is in RGB color space
                    if color.cgColor.numberOfComponents == 2 {
                        let whiteValue = color.cgColor.components?[0]
                        return UIColor(red: whiteValue!, green: whiteValue!, blue: whiteValue!, alpha: 1.0)
                    } else {
                        return color
                    }
                }
                
                let componentsArray = rgbColorsArray.flatMap { color -> [CGFloat] in
                    // let components: UnsafePointer<CGFloat> = color.cgColor.components
                    let components = color.cgColor.components
                    return [components![0], components![1], components![2], 1.0]
                }
                
                drawGradientWithContext(ctx, componentsArray: componentsArray)
            } else {
                var color: UIColor?
                if colorsArray.isEmpty {
                    color = UIColor.white
                } else if colorsArray.count == 1 {
                    color = colorsArray[0]
                } else {
                    // lerpColorMode is true
                    let tAngle = CGFloat(reducedAngle)/360
                    let steps = colorsArray.count - 1
                    let step = 1 / CGFloat(steps)
                    for iStep in 1...steps {
                        let fi = CGFloat(iStep)
                        if tAngle <= fi * step || iStep == steps {
                            let colorT = Utility.inverseLerp(tAngle, minMax: ((fi - 1) * step, fi * step))
                            color = Utility.colorLerp(colorT, minMax: (colorsArray[iStep - 1], colorsArray[iStep]))
                            break
                        }
                    }
                }
                
                if let color = color {
                    fillRectWithContext(ctx, color: color)
                }
            }
            ctx.restoreGState()
            UIGraphicsPopContext()
        }
        
        fileprivate func fillRectWithContext(_ ctx: CGContext!, color: UIColor) {
            ctx.setFillColor(color.cgColor)
            ctx.fill(bounds)
        }
        
        fileprivate func drawGradientWithContext(_ ctx: CGContext!, componentsArray: [CGFloat]) {
            let baseSpace = CGColorSpaceCreateDeviceRGB()
            let locations = locationsCache ?? gradientLocationsForColorCount(componentsArray.count/4, gradientWidth: bounds.size.width)
            let gradient: CGGradient
            
            if let cachedGradient = gradientCache {
                gradient = cachedGradient
            } else {
                guard let cachedGradient = CGGradient(colorSpace: baseSpace,
                                                      colorComponents: componentsArray,
                                                      locations: locations,
                                                      count: componentsArray.count/4) else {
                    return
                }
                
                gradientCache = cachedGradient
                gradient = cachedGradient
            }
            
            let halfX = bounds.size.width / 2.0
            let floatPi = CGFloat(Double.pi)
            let rotateSpeed = clockwise == true ? gradientRotateSpeed : gradientRotateSpeed * -1
            let angleInRadians = Conversion.degreesToRadians(rotateSpeed! * CGFloat(angle) - 90)
            let oppositeAngle = angleInRadians > floatPi ? angleInRadians - floatPi : angleInRadians + floatPi
            
            let startPoint = CGPoint(x: (cos(angleInRadians) * halfX) + halfX, y: (sin(angleInRadians) * halfX) + halfX)
            let endPoint = CGPoint(x: (cos(oppositeAngle) * halfX) + halfX, y: (sin(oppositeAngle) * halfX) + halfX)
            
            ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
        }
        
        fileprivate func gradientLocationsForColorCount(_ colorCount: Int, gradientWidth: CGFloat) -> [CGFloat] {
            if colorCount == 0 || gradientWidth == 0 {
                return []
            } else {
                let progressLineWidth = radius * progressThickness
                let firstPoint = gradientWidth/2 - (radius - progressLineWidth/2)
                let increment = (gradientWidth - (2*firstPoint))/CGFloat(colorCount - 1)
                
                let locationsArray = (0..<colorCount).map { firstPoint + (CGFloat($0) * increment) }
                let result = locationsArray.map { $0 / gradientWidth }
                locationsCache = result
                return result
            }
        }
        
        fileprivate func invalidateGradientCache() {
            gradientCache = nil
            locationsCache = nil
        }
    }
}


struct GlowConstants {
    static let sizeToGlowRatio: CGFloat = 0.00015
    static func glowAmountForAngle(_ angle: Double, glowAmount: CGFloat, glowMode: KDCircularProgressGlowMode, size: CGFloat) -> CGFloat {
        switch glowMode {
        case .forward:
            return CGFloat(angle) * size * sizeToGlowRatio * glowAmount
        case .reverse:
            return CGFloat(360 - angle) * size * sizeToGlowRatio * glowAmount
        case .constant:
            return 360 * size * sizeToGlowRatio * glowAmount
        default:
            return 0
        }
    }
}

struct ExtractedDimensions {
    let reducedAngle: Double
    let width: CGFloat
    let height: CGFloat
    let arcRadius: CGFloat
    let progressLineWidth: CGFloat
    let ctx: CGContext
}
