//
//  ReportPieChartView.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/08.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit

class Slice {
    var category: HistoryCategory
    var percent: CGFloat
    
    init(category: HistoryCategory, percent: CGFloat) {
        self.category = category
        self.percent = percent
    }
}

class ReportPieChartView: UIView {
    
    @IBOutlet var superView: UIView!
    
    static let identifier = "ReportPieChartView"
    static let ANIMATION_DURATION: CGFloat = 0.6
    
    var slices: [Slice]?
    private var sliceIndex: Int = 0
    private var currentPercent: CGFloat = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        guard let view = Bundle.main.loadNibNamed(ReportPieChartView.identifier, owner: self, options: nil)?.first as? UIView else { return }

        addSubview(view)
    }
    
    override func draw(_ rect: CGRect) {
        subviews[0].frame = bounds
    }
    
    private func getDuration(_ slice: Slice) -> CFTimeInterval {
        return CFTimeInterval(slice.percent / 1.0 * ReportPieChartView.ANIMATION_DURATION)
    }
    
    private func percentToRadian(_ percent: CGFloat) -> CGFloat {
        var angle = 270 + percent * 360
        if angle >= 360 {
            angle -= 360
        }
        return angle * CGFloat.pi / 180.0
    }
    
    private func addSlice(_ slice: Slice) {
        if round(slice.percent * 1000) / 10 == 0 { return }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = getDuration(slice)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.delegate = self
        
        let canvasWidth = superView.frame.width
        let path = UIBezierPath(arcCenter: superView.center,
                                radius: canvasWidth * 3 / 8,
                                startAngle: percentToRadian(currentPercent),
                                endAngle: percentToRadian(currentPercent + slice.percent - 0.000001),
                                clockwise: true)
        
        let sliceLayer = CAShapeLayer()
        sliceLayer.path = path.cgPath
        sliceLayer.fillColor = nil
        sliceLayer.strokeColor = UIColor(named: slice.category.imageName + "-color")?.cgColor
        sliceLayer.lineWidth = canvasWidth * 2 / 8
        sliceLayer.strokeEnd = 1
        sliceLayer.add(animation, forKey: animation.keyPath)
        
        superView.layer.addSublayer(sliceLayer)
    }
    
    private func getLabelCenter(_ fromPercent: CGFloat, _ toPercent: CGFloat) -> CGPoint {
        let radius = self.frame.width * 3 / 8
        let labelAngle = percentToRadian((toPercent - fromPercent) / 2 + fromPercent)
        let path = UIBezierPath(arcCenter: self.center,
                                radius: radius,
                                startAngle: labelAngle,
                                endAngle: labelAngle,
                                clockwise: true)
        path.close()
        return path.currentPoint
    }
    
    private func addLabel(_ slice: Slice) {
        let center = self.center
        let labelCenter = getLabelCenter(currentPercent, currentPercent + slice.percent)
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        addSubview(label)
        
        let roundedPercentage = round(slice.percent * 1000) / 10
        
        label.text = roundedPercentage < 5 ? "" : String(format: "\(slice.category.name)\n%.1f%%", roundedPercentage)
          
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: labelCenter.x - center.x),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: labelCenter.y - center.y)
        ])
        self.setNeedsUpdateConstraints()
        self.layoutIfNeeded()
    }
    
    func removeAllLabels() {
        subviews.filter({ $0 is UILabel }).forEach({ $0.removeFromSuperview() })
    }
    
    func animateChart() {
        sliceIndex = 0
        currentPercent = 0.0
        
        if slices != nil && slices!.count > 0 {
            let firstSlice = slices![0]
            addLabel(firstSlice)
            addSlice(firstSlice)
        }
    }
    
}

extension ReportPieChartView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            currentPercent += slices![sliceIndex].percent
            sliceIndex += 1
            if sliceIndex < slices!.count {
                let nextSlice = slices![sliceIndex]
                addLabel(nextSlice)
                addSlice(nextSlice)
            }
        }
    }
}
