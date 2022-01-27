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
    let timeStamp: Int
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
    private let contentView: UIView = UIView()
    
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
        contentView.layer.addSublayer(mainLayer)
        scrollView.addSubview(contentView)
        
        addSubview(scrollView)
        
        layer.addSublayer(gridLayer)
        
        setupScrollView()
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
    }
    
    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        if let data = data {
            let contentSize: CGSize = CGSize(width: CGFloat(data.count) * lineGap + leadingSpace + trailingSpace, height: frame.size.height)
            scrollView.contentSize = contentSize
            mainLayer.frame = CGRect(origin: .zero, size: contentSize)
            contentView.frame = mainLayer.frame
            mainLayer.backgroundColor = UIColor.clear.cgColor
            dataLayer.frame = CGRect(x: 0, y: topSpace, width: mainLayer.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            dataLayer.backgroundColor = UIColor.clear.cgColor
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
            lineLayer.strokeColor = UIColor(named: "humidity-graph-color")?.cgColor
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
    
    private func drawVerticalLines() {
        guard let data = data else { return }
        
        for index in 0..<(data.count - 1) {
            let path: UIBezierPath = UIBezierPath()
            path.move(to: CGPoint(x: lineGap * CGFloat(index + 1) + leadingSpace, y: topSpace))
            path.addLine(to: CGPoint(x: lineGap * CGFloat(index + 1) + leadingSpace, y: mainLayer.frame.size.height - bottomSpace))
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.strokeColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor
            lineLayer.lineDashPattern = [4, 4]
            lineLayer.lineWidth = 0.8
            
            mainLayer.addSublayer(lineLayer)
        }
    }
    
    private func drawLabels() {
        if let data = data, data.count > 0 {
            for index in 0..<data.count {
                let textLayer: CATextLayer = CATextLayer()
                textLayer.frame = CGRect(x: lineGap * CGFloat(index) + leadingSpace, y: mainLayer.frame.size.height - bottomSpace/2 - 8, width: lineGap, height: 30)
                textLayer.foregroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.alignmentMode = CATextLayerAlignmentMode.center
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 11
                
                let date: Date = Date(timeIntervalSince1970: TimeInterval(data[index].timeStamp))
                let dateFormatter: DateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd\nhh:mm a"
                textLayer.string = dateFormatter.string(from: date)
                
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
    
}

extension WeatherGraphView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        print(#function)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print(#function)
    }
    
}
