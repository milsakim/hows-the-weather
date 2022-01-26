//
//  LineChartView.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

struct PointEntry {
    let value: Double
    let humidityValue: Double
    let label: String
}

extension PointEntry: Comparable {
    static func <(lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value < rhs.value
    }
    static func ==(lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value == rhs.value
    }
}

class LineChartView: UIView {
    
    let lineGap: CGFloat = 60.0
    
    let topSpace: CGFloat = 60.0
    let bottomSpace: CGFloat = 60.0
    let leadingSpace: CGFloat = 20.0
    let trailingSpace: CGFloat = 20.0
    
    let topHorizontalLine: CGFloat = 110.0 / 100.0
    
    var data: [PointEntry]? {
        didSet {
            setNeedsLayout()
        }
    }

    private let dataLayer: CALayer = CALayer()
    
    private let mainLayer: CALayer = CALayer()
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private let gridLayer: CALayer = CALayer()
    
    private var dataPoints: [CGPoint]?
    private var humidityDataPoints: [CGPoint]?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        mainLayer.addSublayer(dataLayer)
        
        scrollView.layer.addSublayer(mainLayer)
        
        layer.addSublayer(gridLayer)
        
        addSubview(scrollView)
    }
    
    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        if let data = data {
            let contentSize: CGSize = CGSize(width: CGFloat(data.count) * lineGap + leadingSpace + trailingSpace, height: frame.size.height)
            scrollView.contentSize = contentSize
            mainLayer.frame = CGRect(origin: .zero, size: contentSize)
            dataLayer.frame = CGRect(x: 0, y: topSpace, width: mainLayer.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            gridLayer.frame = CGRect(x: 0, y: topSpace, width: self.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            
            dataPoints = convertDataEntriesToPoints(data: data)
            clean()
            drawHorizontalLines()
            drawVerticalLines()
            drawChart()
            drawLabels()
        }
    }
    
    private func convertDataEntriesToPoints(data: [PointEntry]) -> [CGPoint] {
        if let maxValue = data.max()?.value, let minValue = data.min()?.value {
            var result: [CGPoint] = []
            let minMaxRange: CGFloat = CGFloat(maxValue - minValue) * topHorizontalLine
            
            for index in 0..<data.count {
                let height = dataLayer.frame.height * (1 - ((CGFloat(data[index].value) - CGFloat(minValue)) / minMaxRange))
                let point = CGPoint(x: CGFloat(index) * lineGap + lineGap / 2 + leadingSpace, y: height)
                result.append(point)
            }
            
            return result
        }
        
        return []
    }
    
    private func drawChart() {
        if let dataPoints = dataPoints,
            dataPoints.count > 0,
            let path = createPath() {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.black.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }
    
    private func createPath() -> UIBezierPath? {
        guard let dataPoints = dataPoints, dataPoints.count > 0 else {
            return nil
        }
        let path = UIBezierPath()
        path.move(to: dataPoints[0])
        
        for i in 1..<dataPoints.count {
            path.addLine(to: dataPoints[i])
        }
        return path
    }
    
    private func drawHumidityHorizontalLines() {
        
    }
    
    private func drawHorizontalLines() {
        guard let data = data else {
            return
        }
        
        var gridValues: [CGFloat]? = nil
        if data.count < 4 && data.count > 0 {
            gridValues = [0, 1]
        } else if data.count >= 4 {
            gridValues = [0, 0.25, 0.5, 0.75, 1]
        }
        if let gridValues = gridValues {
            for value in gridValues {
                let height = value * gridLayer.frame.size.height
                
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: gridLayer.frame.size.width, y: height))
                
                let lineLayer = CAShapeLayer()
                lineLayer.path = path.cgPath
                lineLayer.fillColor = UIColor.clear.cgColor
                lineLayer.strokeColor = #colorLiteral(red: 0.2784313725, green: 0.5411764706, blue: 0.7333333333, alpha: 1).cgColor
                lineLayer.lineWidth = 0.5
                if (value > 0.0 && value < 1.0) {
                    lineLayer.lineDashPattern = [4, 4]
                }
                
                gridLayer.addSublayer(lineLayer)
                
                var minMaxGap:CGFloat = 0
                var lineValue:Int = 0
                if let max = data.max()?.value,
                    let min = data.min()?.value {
                    minMaxGap = CGFloat(max - min) * topHorizontalLine
                    lineValue = Int((1-value) * minMaxGap) + Int(min)
                }
                
                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: 4, y: height, width: 50, height: 16)
                textLayer.foregroundColor = #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 12
                textLayer.string = "\(lineValue)"
                
                gridLayer.addSublayer(textLayer)
            }
        }
    }
    
    private func drawVerticalLines() {
        guard let data = data else { return }
        
        for index in 0..<(data.count - 1) {
            let path: UIBezierPath = UIBezierPath()
            path.move(to: CGPoint(x: lineGap * CGFloat(index + 1) + leadingSpace, y: topSpace))
            path.addLine(to: CGPoint(x: lineGap * CGFloat(index + 1) + leadingSpace, y: mainLayer.frame.size.height - bottomSpace))
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.strokeColor = UIColor.magenta.cgColor
            lineLayer.lineWidth = 0.5
            
            mainLayer.addSublayer(lineLayer)
        }
    }
    
    private func drawLabels() {
        if let data = data, data.count > 0 {
            for index in 0..<data.count {
                let textLayer: CATextLayer = CATextLayer()
                textLayer.frame = CGRect(x: lineGap * CGFloat(index) + leadingSpace, y: mainLayer.frame.size.height - bottomSpace/2 - 8, width: lineGap, height: 30)
                textLayer.foregroundColor = #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.black.cgColor
                textLayer.alignmentMode = CATextLayerAlignmentMode.center
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 11
                textLayer.string = "\(index)\ntest"
                mainLayer.addSublayer(textLayer)
            }
        }
    }
    
    private func clean() {
        mainLayer.sublayers?.forEach({
            if $0 is CATextLayer {
                $0.removeFromSuperlayer()
            }
        })
        dataLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        gridLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
