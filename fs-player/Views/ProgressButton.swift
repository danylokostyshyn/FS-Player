//
//  ProgressButton.swift
//  fs-player
//
//  Created by Danylo Kostyshyn on 10/29/15.
//  Copyright © 2015 kostyshyn. All rights reserved.
//

import UIKit

@IBDesignable
class ProgressButton: UIButton {
    
    @IBInspectable var progress: Double = 0.0 {
        didSet {
            updateLayerProperties()
        }
    }
    
    private var backgroundLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.text = nil
        
        let color = tintColor.CGColor
        
        // Circle background layer
        if (backgroundLayer == nil) {
            let lineWidth: CGFloat = 1.0
            let rect = CGRectInset(bounds, lineWidth / 2.0, lineWidth / 2.0)

            backgroundLayer = CAShapeLayer()
            backgroundLayer.path = UIBezierPath(ovalInRect:rect).CGPath
            backgroundLayer.fillColor = nil
            backgroundLayer.lineWidth = lineWidth
            backgroundLayer.strokeColor = color
            
            layer.addSublayer(backgroundLayer)
        }
        backgroundLayer.frame = layer.bounds
        
        // Progress layer
        if (progressLayer == nil) {
            let lineWidth: CGFloat = 4.0
            let rect = CGRectInset(bounds, lineWidth / 2.0, lineWidth / 2.0)

            progressLayer = CAShapeLayer()
            progressLayer.path = UIBezierPath(ovalInRect:rect).CGPath
            progressLayer.fillColor = nil
            progressLayer.lineWidth = lineWidth
            progressLayer.strokeColor = color
            progressLayer.transform = CATransform3DRotate(progressLayer.transform, CGFloat(-M_PI/2.0), 0.0, 0.0, 1.0)
            progressLayer.strokeEnd = CGFloat(progress)
            
            layer.addSublayer(progressLayer)
        }
        progressLayer.frame = layer.bounds
    }
    
    func updateLayerProperties() {
        if (progressLayer != nil) {
            progressLayer.strokeEnd = CGFloat(progress)
        }
    }

}
