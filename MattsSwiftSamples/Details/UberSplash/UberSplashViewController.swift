//
//  UberSplashViewController.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 03/08/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import UIKit

private let blue = UIColor(red: 15/255, green: 78/255, blue: 101/255, alpha: 1)


class UberSplashViewController:DetailViewController {
    
    let animatedLogoView: AnimatedLogoView = AnimatedLogoView(frame: CGRect(x: 0.0, y: 0.0, width: 90.0, height: 90.0))
    
    override func viewDidLoad() {
        view.backgroundColor = blue

        view.addSubview(animatedLogoView)
        animatedLogoView.layer.position = view.layer.position
        
        animatedLogoView.startAnimating()
    }
}

let kAnimationDuration: CFTimeInterval = 3.0

/// The length of the second part of the duration
let kAnimationDurationDelay: CFTimeInterval = 0.5

/// The offset between the AnimatedULogoView and the background Grid
let kAnimationTimeOffset: CFTimeInterval = 0.35 * kAnimationDuration

/// The ripple magnitude. Increase by small amounts for amusement ( <= .2) :]
let kRippleMagnitudeMultiplier: CGFloat = 0.025

class AnimatedLogoView:UIView {
    
    
    fileprivate let strokeEndTimingFunction   = CAMediaTimingFunction(controlPoints: 1.00, 0.0, 0.35, 1.0)
    fileprivate let squareLayerTimingFunction      = CAMediaTimingFunction(controlPoints: 0.25, 0.0, 0.20, 1.0)
    fileprivate let circleLayerTimingFunction   = CAMediaTimingFunction(controlPoints: 0.65, 0.0, 0.40, 1.0)
    fileprivate let fadeInSquareTimingFunction = CAMediaTimingFunction(controlPoints: 0.15, 0, 0.85, 1.0)
    
    fileprivate let radius: CGFloat = 37.5
    fileprivate let squareLayerLength = 21.0
    fileprivate let startTimeOffset = 0.7 * 3.0
    
    fileprivate var circleLayer: CAShapeLayer!
    fileprivate var squareLayer: CAShapeLayer!
    fileprivate var lineLayer: CAShapeLayer!
    fileprivate var maskLayer: CAShapeLayer!
    
    var beginTime: CFTimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        circleLayer = generateCircleLayer()
        lineLayer = generateLineLayer()
        squareLayer = generateSquareLayer()
        maskLayer = generateMaskLayer()
        
        layer.mask = maskLayer
        layer.addSublayer(circleLayer)
        layer.addSublayer(lineLayer)
        layer.addSublayer(squareLayer)
        
    }
    
    func startAnimating() {
        beginTime = CACurrentMediaTime()
        layer.anchorPoint = CGPoint.zero
        
        animateMaskLayer()
        animateCircleLayer()
        animateLineLayer()
        animateSquareLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension AnimatedLogoView {
    fileprivate func generateCircleLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.lineWidth = radius
        layer.path = UIBezierPath(arcCenter: CGPoint.zero, radius: radius/2, startAngle: -CGFloat(M_PI_2), endAngle: CGFloat(3*M_PI_2), clockwise: true).cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }
    
    fileprivate func generateMaskLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: -radius, y: -radius, width: radius * 2.0, height: radius * 2.0)
        layer.allowsGroupOpacity = true
        layer.backgroundColor = UIColor.white.cgColor
        return layer
    }

    
    fileprivate func generateLineLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.position = CGPoint.zero
        layer.frame = CGRect.zero
        layer.allowsGroupOpacity = true
        layer.lineWidth = 5.0
        layer.strokeColor = blue.cgColor
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint.zero)
        bezierPath.addLine(to: CGPoint(x: 0.0, y: -radius))
        
        layer.path = bezierPath.cgPath
        return layer
    }
    
    fileprivate func generateSquareLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.position = CGPoint.zero
        layer.frame = CGRect(x: -squareLayerLength / 2.0, y: -squareLayerLength / 2.0, width: squareLayerLength, height: squareLayerLength)
        layer.cornerRadius = 1.5
        layer.allowsGroupOpacity = true
        layer.backgroundColor = blue.cgColor
        
        return layer
    }
}

extension AnimatedLogoView {
    
    fileprivate func animateMaskLayer() {
        // bounds
        let boundsAnimation = CABasicAnimation(keyPath: "bounds")
        boundsAnimation.fromValue = NSValue(cgRect: CGRect(x: 0.0, y: 0.0, width: radius * 2.0, height: radius * 2))
        boundsAnimation.toValue = NSValue(cgRect: CGRect(x: 0.0, y: 0.0, width: 2.0/3.0 * squareLayerLength, height: 2.0/3.0 * squareLayerLength))
        boundsAnimation.duration = kAnimationDurationDelay
        boundsAnimation.beginTime = kAnimationDuration - kAnimationDurationDelay
        boundsAnimation.timingFunction = circleLayerTimingFunction
        
        // cornerRadius
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerRadiusAnimation.beginTime = kAnimationDuration - kAnimationDurationDelay
        cornerRadiusAnimation.duration = kAnimationDurationDelay
        cornerRadiusAnimation.fromValue = radius
        cornerRadiusAnimation.toValue = 2
        cornerRadiusAnimation.timingFunction = circleLayerTimingFunction

        let groupAnimation = CAAnimationGroup()
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = kCAFillModeBoth
        groupAnimation.beginTime = beginTime
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.duration = kAnimationDuration
        groupAnimation.animations = [boundsAnimation, cornerRadiusAnimation]
        groupAnimation.timeOffset = startTimeOffset
        maskLayer.add(groupAnimation, forKey: "looping")
    }
    
    fileprivate func animateCircleLayer() {
        let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.timingFunction = strokeEndTimingFunction
        strokeEndAnimation.duration = kAnimationDuration - kAnimationDurationDelay
        strokeEndAnimation.values = [0.0, 1.0]
        strokeEndAnimation.keyTimes = [0.0, 1.0]
        
        // transform
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.timingFunction = strokeEndTimingFunction
        transformAnimation.duration = kAnimationDuration - kAnimationDurationDelay
        
        var startingTransform = CATransform3DMakeRotation(-CGFloat(M_PI_4), 0, 0, 1)
        startingTransform = CATransform3DScale(startingTransform, 0.25, 0.25, 1)
        transformAnimation.fromValue = NSValue(caTransform3D: startingTransform)
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [strokeEndAnimation, transformAnimation]
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.duration = kAnimationDuration
        groupAnimation.beginTime = beginTime
        groupAnimation.timeOffset = startTimeOffset
        
        circleLayer.add(groupAnimation, forKey: "looping")
    }
    
    fileprivate func animateLineLayer() {
        let lineWidthAnimation = CAKeyframeAnimation(keyPath: "lineWidth")
        lineWidthAnimation.values = [0.0, 5.0, 0.0]
        lineWidthAnimation.timingFunctions = [strokeEndTimingFunction, circleLayerTimingFunction]
        lineWidthAnimation.duration = kAnimationDuration
        lineWidthAnimation.keyTimes = [0.0, NSNumber(value:1.0-kAnimationDurationDelay/kAnimationDuration), 1.0]
        
        let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
        transformAnimation.timingFunctions = [strokeEndTimingFunction, circleLayerTimingFunction]
        transformAnimation.duration = kAnimationDuration
        transformAnimation.keyTimes = [0.0, NSNumber(value:1.0-kAnimationDurationDelay/kAnimationDuration), 1.0]
        
        var transform = CATransform3DMakeRotation(-CGFloat(M_PI_4), 0.0, 0.0, 1.0)
        transform = CATransform3DScale(transform, 0.25, 0.25, 1.0)
        transformAnimation.values = [NSValue(caTransform3D: transform),
                                     NSValue(caTransform3D: CATransform3DIdentity),
                                     NSValue(caTransform3D: CATransform3DMakeScale(0.15, 0.15, 1.0))]
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.duration = kAnimationDuration
        groupAnimation.beginTime = beginTime
        groupAnimation.animations = [lineWidthAnimation, transformAnimation]
        groupAnimation.timeOffset = startTimeOffset
        
        lineLayer.add(groupAnimation, forKey: "looping")
    }
    
    fileprivate func animateSquareLayer() {
        let b1 = NSValue(cgRect: CGRect(x: 0.0, y: 0.0, width: 2.0/3.0 * squareLayerLength, height: 2.0/3.0  * squareLayerLength))
        let b2 = NSValue(cgRect: CGRect(x: 0.0, y: 0.0, width: squareLayerLength, height: squareLayerLength))
        let b3 = NSValue(cgRect: CGRect.zero)

        let boundsAnimation = CAKeyframeAnimation(keyPath: "bounds")
        boundsAnimation.values = [b1, b2, b3]
        boundsAnimation.timingFunctions = [fadeInSquareTimingFunction, squareLayerTimingFunction]
        boundsAnimation.duration = kAnimationDuration
        boundsAnimation.keyTimes = [0, NSNumber(value:1.0-kAnimationDurationDelay/kAnimationDuration), 1.0]
        
        // backgroundColor
        let backgroundColorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        backgroundColorAnimation.fromValue = UIColor.white.cgColor
        backgroundColorAnimation.toValue = blue.cgColor
        backgroundColorAnimation.timingFunction = squareLayerTimingFunction
        backgroundColorAnimation.fillMode = kCAFillModeBoth
        backgroundColorAnimation.beginTime = kAnimationDurationDelay * 2.0 / kAnimationDuration
        backgroundColorAnimation.duration = kAnimationDuration / (kAnimationDuration - kAnimationDurationDelay)

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [boundsAnimation, backgroundColorAnimation]
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.duration = kAnimationDuration
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.beginTime = beginTime
        groupAnimation.timeOffset = startTimeOffset
        squareLayer.add(groupAnimation, forKey: "looping")
    }
}
