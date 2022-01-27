//
//  LineChartView.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

struct PointEntry {
    let minTempValue: Double
    let maxTempValue: Double
    let humidityValue: Double
    let label: String
}

class WeatherGraphView: UIView {
    
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
    
    private var minTempDataPoints: [CGPoint]?
    private var maxTempDataPoints: [CGPoint]?
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
        addSubview(scrollView)
        
        layer.addSublayer(gridLayer)
    }
    
    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        if let data = data {
            let contentSize: CGSize = CGSize(width: CGFloat(data.count) * lineGap + leadingSpace + trailingSpace, height: frame.size.height)
            scrollView.contentSize = contentSize
            mainLayer.frame = CGRect(origin: .zero, size: contentSize)
            dataLayer.frame = CGRect(x: 0, y: topSpace, width: mainLayer.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            dataLayer.backgroundColor = UIColor.green.cgColor
            gridLayer.frame = CGRect(x: 0, y: topSpace, width: self.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            
            let minTempData: [Double] = data.compactMap({ $0.minTempValue })
            print(minTempData.count)
            let maxTempData: [Double] = data.compactMap({ $0.maxTempValue })
            let tempRange: (Double?, Double?) = (minTempData.min(), maxTempData.max())
            
            let humidityData: [Double] = data.compactMap({ $0.humidityValue })
            let humidityRange: (Double?, Double?) = (humidityData.min(), humidityData.max())
            
            minTempDataPoints = convertDataEntriesToPoints(data: minTempData, range: tempRange)
            maxTempDataPoints = convertDataEntriesToPoints(data: maxTempData, range: tempRange)
            humidityDataPoints = convertDataEntriesToPoints(data: humidityData, range: humidityRange)
            
            clean()
            
            drawHorizontalLines()
            drawVerticalLines()
            drawChart()
            drawLabels()
        }
    }
    
    private func convertDataEntriesToPoints(data: [Double], range: (min: Double?, max: Double?)) -> [CGPoint] {
        if let minValue: Double = range.min, let maxValue: Double = range.max {
            var result: [CGPoint] = []
            let ratio: CGFloat = dataLayer.frame.height / CGFloat(maxValue - minValue)
            
            for index in 0..<data.count {
                let xPos: CGFloat = CGFloat(index) * lineGap + lineGap / 2 + leadingSpace
                let yPos: CGFloat = (data[index] - minValue) * ratio
                result.append(CGPoint(x: xPos, y: yPos))
            }

            return result
        }
        
        return []
    }
    
    private func drawChart() {
        if let maxTempDataPoints = maxTempDataPoints, maxTempDataPoints.count > 0, let path: UIBezierPath = createPath(from: maxTempDataPoints) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.red.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
        
        if let minTempDataPoints = minTempDataPoints, minTempDataPoints.count > 0, let path: UIBezierPath = createPath(from: minTempDataPoints) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.blue.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
        
        if let humidityDataPoints = humidityDataPoints, humidityDataPoints.count > 0, let path = createPath(from: humidityDataPoints) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.black.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }
    
    private func createPath(from points: [CGPoint]) -> UIBezierPath? {
        guard points.count > 0 else {
            return nil
        }
        let path = UIBezierPath()
        path.move(to: points[0])
        
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        return path
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
                /*
                 if let max = data.max()?.value,
                 let min = data.min()?.value {
                 minMaxGap = CGFloat(max - min) * topHorizontalLine
                 lineValue = Int((1-value) * minMaxGap) + Int(min)
                 }
                 */
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
            if $0 is CATextLayer || $0 is CAShapeLayer {
                $0.removeFromSuperlayer()
            }
        })
        dataLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        gridLayer.sublayers?.forEach({
            $0.removeFromSuperlayer()
        })
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

extension WeatherGraphView: UIScrollViewDelegate {
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print(#function)
    }
    
}
