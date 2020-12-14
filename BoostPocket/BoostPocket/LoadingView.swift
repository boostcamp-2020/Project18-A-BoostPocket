//
//  LoadingView.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/14.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    private let paintAnimation = CABasicAnimation(keyPath: "strokeEnd")
    private let positionAnimation = CAKeyframeAnimation(keyPath: "position")
    
    override func draw(_ rect: CGRect) {
        layer.backgroundColor = UIColor(named: "transportation-color")?.cgColor
        
        let path = makePath()
        configureAnimations(with: path)
        
        let imageLayer = CALayer()
        let airplaneImage = UIImage(named: "airplane")?.cgImage
        imageLayer.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        imageLayer.position = CGPoint(x: self.frame.width, y: self.frame.height)
        imageLayer.contents = airplaneImage
        self.layer.addSublayer(imageLayer)
        imageLayer.add(positionAnimation, forKey: positionAnimation.keyPath)
        
        let pathLayer = CAShapeLayer()
        pathLayer.path = path.cgPath
        pathLayer.fillColor = nil
        pathLayer.strokeColor = UIColor.white.cgColor
        pathLayer.lineWidth = 2
        pathLayer.strokeEnd = 1
        pathLayer.lineDashPattern = [NSNumber(value: 10)]
        self.layer.addSublayer(pathLayer)
        pathLayer.add(paintAnimation, forKey: paintAnimation.keyPath)
    }
    
    private func makePath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = self.frame.width
        let height = self.frame.height
        
        path.move(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addCurve(to: CGPoint(x: width * 0.26, y: height * 0.12), controlPoint1: CGPoint(x: 0, y: height), controlPoint2: CGPoint(x: 0, y: height * 0.12))
        path.addQuadCurve(to: CGPoint(x: width * 0.4, y: height * 0.43), controlPoint: CGPoint(x: self.frame.width, y: height * 0.18))
        path.addQuadCurve(to: CGPoint(x: 0, y: height * 0.86), controlPoint: CGPoint(x: width * 1.26, y: height * 0.55))
        return path
    }
    
    private func configureAnimations(with path: UIBezierPath) {
        paintAnimation.fromValue = 0
        paintAnimation.toValue = 1
        paintAnimation.duration = 3
        paintAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        paintAnimation.delegate = self
        
        positionAnimation.path = path.cgPath
        positionAnimation.duration = 3
        positionAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        positionAnimation.rotationMode = .rotateAuto
    }
}

extension LoadingView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
