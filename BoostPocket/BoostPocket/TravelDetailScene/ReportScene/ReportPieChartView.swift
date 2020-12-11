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
    var sliceIndex: Int = 0
    var currentPercent: CGFloat = 0.0
    
    // 스토리보드로 뷰가 생성되지만 nib으로 불러온 뷰를 추가해줌
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        guard let view = Bundle.main.loadNibNamed(ReportPieChartView.identifier, owner: self, options: nil)?.first as? UIView else { return }

        addSubview(view)
    }
    
    override func draw(_ rect: CGRect) {
        // nib으로 불러온 뷰의 크기를 현재 뷰의 크기와 맞춤
        subviews[0].frame = bounds
    }
    
    // 각각의 슬라이스는 총 애니메이션 duration 중 슬라이스의 퍼센트 만큼 애니메이션 시간을 차지함
    private func getDuration(_ slice: Slice) -> CFTimeInterval {
        return CFTimeInterval(slice.percent / 1.0 * ReportPieChartView.ANIMATION_DURATION)
    }
    
    private func percentToRadian(_ percent: CGFloat) -> CGFloat {
        //Because angle starts wtih X positive axis, add 270 degrees to rotate it to Y positive axis.
        var angle = 270 + percent * 360
        if angle >= 360 {
            angle -= 360
        }
        return angle * CGFloat.pi / 180.0
    }
    
    // 각각의 퍼센트와 색이 담긴 슬라이스를 파라미터로 주입하여 그림
    private func addSlice(_ slice: Slice) {
        if round(slice.percent * 1000) / 10 == 0 { return }
        // strikeEnd키로 애니메이션 생성.
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        // strokeEnd의 경우 value 범위는 0~1까지. 모든 범위에 해당하는 애니메이션
        animation.fromValue = 0
        animation.toValue = 1
        // 각 슬라이스의 애니메이션 시간을 받아옴
        animation.duration = getDuration(slice)
        // CAMediaTimingFunction.linear -> 일정한 속도
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.delegate = self
        
        let canvasWidth = superView.frame.width
        let path = UIBezierPath(arcCenter: superView.center,
                                radius: canvasWidth * 3 / 8,
                                // 0 라디안부터 퍼센트에 해당하는 만큼의 라디안까지 path 생성
                                startAngle: percentToRadian(currentPercent),
                                endAngle: percentToRadian(currentPercent + slice.percent - 0.000001),
                                clockwise: true)
        
        // 다각형을 그리기 위한 레이어 생성
        let sliceLayer = CAShapeLayer()
        // path 등록
        sliceLayer.path = path.cgPath
        // 여기서 채워지는 컬러는 path의 시작과 끝점을 이어 만든 범위
        sliceLayer.fillColor = nil
        sliceLayer.strokeColor = UIColor(named: slice.category.imageName + "-color")?.cgColor
        // 원 안을 채우는게 아니라 라인을 겁~~나 두껍게 그림
        sliceLayer.lineWidth = canvasWidth * 2 / 8
        // layer를 그리는 범위. 1이 맥시멈이고 그것보다 작은 경우 비율만큼만 그려짐
        sliceLayer.strokeEnd = 1
        // 애니메이션 등록
        sliceLayer.add(animation, forKey: animation.keyPath)
        
        // 만든 레이어를 추가해줌
        superView.layer.addSublayer(sliceLayer)
    }
    
    private func getLabelCenter(_ fromPercent: CGFloat, _ toPercent: CGFloat) -> CGPoint {
        let radius = self.frame.width * 3 / 8
        // 중간 지점 찾기
        let labelAngle = percentToRadian((toPercent - fromPercent) / 2 + fromPercent)
        let path = UIBezierPath(arcCenter: self.center,
                                radius: radius,
                                startAngle: labelAngle,
                                endAngle: labelAngle,
                                clockwise: true)
        path.close()
        return path.currentPoint
    }
    
    // 레이블 추가 함수 - 이건 기존거 쓰기로...
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
