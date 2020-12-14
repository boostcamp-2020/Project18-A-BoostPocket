//
//  LoadingViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/14.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let curveView = CurveView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        curveView.center = self.view.center
        self.view.addSubview(curveView)
    }
}

class CurveView: UIView {
    
    override func draw(_ rect: CGRect) {
        layer.backgroundColor = UIColor(named: "transportation-color")?.cgColor
        let path = UIBezierPath()
        
        let width = self.frame.width
        let height = self.frame.height
        
        path.move(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addCurve(to: CGPoint(x: width * 0.26, y: height * 0.12), controlPoint1: CGPoint(x: 0, y: height), controlPoint2: CGPoint(x: 0, y: height * 0.12))
        path.addQuadCurve(to: CGPoint(x: width * 0.4, y: height * 0.43), controlPoint: CGPoint(x: self.frame.width, y: height * 0.18))
        path.addQuadCurve(to: CGPoint(x: 0, y: height * 0.86), controlPoint: CGPoint(x: width * 1.26, y: height * 0.55))
        
        // 그려주는 애니메이션
        let paintAnimation = CABasicAnimation(keyPath: "strokeEnd")
        paintAnimation.fromValue = 0
        paintAnimation.toValue = 1
        paintAnimation.duration = 3
        paintAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        paintAnimation.delegate = self
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2.0)
        rotateAnimation.duration = 3
        
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.path = path.cgPath
        positionAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        positionAnimation.rotationMode = .rotateAuto
        
        let imageLayer = CALayer()
        let image2 = UIImage(systemName: "trash")?.cgImage
        imageLayer.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        imageLayer.position = CGPoint(x: self.frame.width, y: self.frame.height)
        imageLayer.contents = image2
        self.layer.addSublayer(imageLayer)

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [rotateAnimation, positionAnimation]
        animationGroup.duration = 3
        animationGroup.delegate = self
        animationGroup.autoreverses = false
        animationGroup.isRemovedOnCompletion = true
        imageLayer.add(animationGroup, forKey: "multipleAnimationsKey")
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = nil
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 2
        layer.strokeEnd = 1
        layer.lineDashPattern = [NSNumber(integerLiteral: 10)]
        layer.add(paintAnimation, forKey: paintAnimation.keyPath)
        self.layer.addSublayer(layer)
    }
}

extension CurveView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.getParentViewController()?.navigationController?.navigationBar.isHidden = false
        self.removeFromSuperview()
    }
}

extension UIResponder {
    func getParentViewController() -> UIViewController? {
        if self.next is UIViewController {
            return self.next as? UIViewController
        } else {
            if let next = self.next {
                return next.getParentViewController()
            } else { return nil }
        }
    }
}
