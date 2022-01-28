//
//  LineChartView.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

struct GraphPointData {
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
    
    var data: [GraphPointData]? {
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
    
    private var minTempColor: CGColor {
        UIColor(named: "min-temp-graph-color")?.cgColor ?? UIColor.blue.cgColor
    }
    private var maxTempColor: CGColor {
        UIColor(named: "max-temp-graph-color")?.cgColor ?? UIColor.red.cgColor
    }
    
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
            drawDots()
            drawDataLabels()
            drawDateLabels()
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
    
    
    private func convertDataEntriesToPoints(data: [Double], range: (min: Double?, max: Double?)) -> [CGPoint] {
        if let minValue: Double = range.min, let maxValue: Double = range.max {
            var result: [CGPoint] = []
            let ratio: CGFloat = dataLayer.frame.height / CGFloat(maxValue - minValue)
            
            for index in 0..<data.count {
                let xPos: CGFloat = CGFloat(index) * lineGap + lineGap / 2 + leadingSpace
                let yPos: CGFloat = dataLayer.frame.height - (data[index] - minValue) * ratio
                result.append(CGPoint(x: xPos, y: yPos))
            }
            
            return result
        }
        
        return []
    }
    
    private func drawChart() {
        // 최고 온도 그래프
        if let maxTempDataPoints = maxTempDataPoints, maxTempDataPoints.count > 0, let path: UIBezierPath = createPath(from: maxTempDataPoints) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.lineWidth = 3.0
            lineLayer.strokeColor = maxTempColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
        // 최저 온도 그래프
        if let minTempDataPoints = minTempDataPoints, minTempDataPoints.count > 0, let path: UIBezierPath = createPath(from: minTempDataPoints) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.lineWidth = 3.0
            lineLayer.lineDashPattern = [10, 5, 5, 5]
            lineLayer.strokeColor =  minTempColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
        // 습도 그래프
        if let humidityDataPoints = humidityDataPoints, humidityDataPoints.count > 0, let path = createPath(from: humidityDataPoints) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.lineWidth = 3.0
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
            
            dataLayer.addSublayer(lineLayer)
        }
    }
    
    private func drawDateLabels() {
        if let data = data, data.count > 0 {
            for index in 0..<data.count {
                let textLayer: CATextLayer = CATextLayer()
                textLayer.frame = CGRect(x: lineGap * CGFloat(index) + leadingSpace, y: mainLayer.frame.size.height - bottomSpace/2 - 8, width: lineGap, height: 30)
                textLayer.foregroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.alignmentMode = .center
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
    
    private func drawDots() {
        if let minTempDataPoints = minTempDataPoints {
            for minTempDataPoint in minTempDataPoints {
                let dotRadius: CGFloat = 8
                let dotLayer: CALayer = CALayer()
                dotLayer.frame = CGRect(x: minTempDataPoint.x - (dotRadius / 2), y: minTempDataPoint.y - (dotRadius / 2), width: dotRadius, height: dotRadius)
                dotLayer.backgroundColor = minTempColor
                dotLayer.cornerRadius = dotRadius / 2
                dataLayer.addSublayer(dotLayer)
            }
        }
        
        if let maxTempDataPoints = maxTempDataPoints {
            for maxTempDataPoint in maxTempDataPoints {
                let dotRadius: CGFloat = 8
                let dotLayer: CALayer = CALayer()
                dotLayer.frame = CGRect(x: maxTempDataPoint.x - (dotRadius / 2), y: maxTempDataPoint.y - (dotRadius / 2), width: dotRadius, height: dotRadius)
                dotLayer.backgroundColor = maxTempColor
                dotLayer.cornerRadius = dotRadius / 2
                dataLayer.addSublayer(dotLayer)
            }
        }
        
        if let humidityDataPoints = humidityDataPoints {
            for humidityDataPoint in humidityDataPoints {
                let dotRadius: CGFloat = 8
                let dotLayer: CALayer = CALayer()
                dotLayer.frame = CGRect(x: humidityDataPoint.x - (dotRadius / 2), y: humidityDataPoint.y - (dotRadius / 2), width: dotRadius, height: dotRadius)
                dotLayer.backgroundColor = UIColor(named: "humidity-graph-color")?.cgColor ?? UIColor.black.cgColor
                dotLayer.cornerRadius = dotRadius / 2
                dataLayer.addSublayer(dotLayer)
            }
        }
    }
    
    private func drawDataLabels() {
        guard let data = data, let minTempDataPoints = minTempDataPoints, let maxTempDataPoints = maxTempDataPoints, let humidityDataPoints = humidityDataPoints else {
            return
        }

        for dataIndex in 0..<data.count {
            let labelLayerHeight: CGFloat = 15
            let fontSize: CGFloat = 11
            let widthPadding: CGFloat = 4.0
            let gap: CGFloat = 4.0

            let minTempString: String = "\(data[dataIndex].minTempValue)℃"
            let minTempStringWidth: CGFloat = (minTempString as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width
            let minTempLabelLayerWidth: CGFloat = minTempStringWidth + widthPadding
            let minTempLabelLayer: CATextLayer = CATextLayer()
            minTempLabelLayer.frame = CGRect(x: minTempDataPoints[dataIndex].x - (minTempLabelLayerWidth / 2), y: minTempDataPoints[dataIndex].y - labelLayerHeight - gap, width: minTempLabelLayerWidth, height: labelLayerHeight)
            minTempLabelLayer.backgroundColor = UIColor(named: "graph-label-background-color")?.cgColor ?? UIColor.lightGray.cgColor.copy(alpha: 0.5)
            minTempLabelLayer.borderColor = UIColor.gray.cgColor
            minTempLabelLayer.borderWidth = 0.5
            minTempLabelLayer.cornerRadius = labelLayerHeight / 2
            minTempLabelLayer.alignmentMode = .center
            minTempLabelLayer.contentsScale = UIScreen.main.scale
            minTempLabelLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            minTempLabelLayer.foregroundColor = minTempColor
            minTempLabelLayer.fontSize = fontSize
            minTempLabelLayer.string = minTempString
            dataLayer.addSublayer(minTempLabelLayer)
            
            let maxTempString: String = "\(data[dataIndex].maxTempValue)℃"
            let maxTempStringWidth: CGFloat = (maxTempString as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width
            let maxTempLabelLayerWidth: CGFloat = maxTempStringWidth + widthPadding
            let maxTempLabelLayer: CATextLayer = CATextLayer()
            maxTempLabelLayer.frame = CGRect(x: maxTempDataPoints[dataIndex].x - (minTempLabelLayerWidth / 2), y: maxTempDataPoints[dataIndex].y - labelLayerHeight - gap, width: maxTempLabelLayerWidth, height: labelLayerHeight)
            maxTempLabelLayer.backgroundColor = UIColor(named: "graph-label-background-color")?.cgColor ?? UIColor.lightGray.cgColor.copy(alpha: 0.5)
            maxTempLabelLayer.cornerRadius = labelLayerHeight / 2
            maxTempLabelLayer.borderColor = UIColor.gray.cgColor
            maxTempLabelLayer.borderWidth = 0.5
            maxTempLabelLayer.alignmentMode = .center
            maxTempLabelLayer.contentsScale = UIScreen.main.scale
            maxTempLabelLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            maxTempLabelLayer.foregroundColor = maxTempColor
            maxTempLabelLayer.fontSize = fontSize
            maxTempLabelLayer.string = maxTempString
            dataLayer.addSublayer(maxTempLabelLayer)
            
            let humidityString: String = "\(data[dataIndex].humidityValue)%"
            let humidityStringWidth: CGFloat = (humidityString as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width
            let humidityLabelLayerWidth: CGFloat = humidityStringWidth + widthPadding
            let humidityLabelLayer: CATextLayer = CATextLayer()
            humidityLabelLayer.frame = CGRect(x: humidityDataPoints[dataIndex].x - (humidityLabelLayerWidth / 2), y: humidityDataPoints[dataIndex].y - labelLayerHeight - gap, width: humidityLabelLayerWidth, height: labelLayerHeight)
            humidityLabelLayer.alignmentMode = .center
            humidityLabelLayer.contentsScale = UIScreen.main.scale
            humidityLabelLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            humidityLabelLayer.foregroundColor = UIColor(named: "humidity-graph-color")?.cgColor ?? UIColor.black.cgColor
            humidityLabelLayer.backgroundColor = UIColor(named: "graph-label-background-color")?.cgColor ?? UIColor.lightGray.cgColor.copy(alpha: 0.5)
            humidityLabelLayer.borderColor = UIColor.gray.cgColor
            humidityLabelLayer.borderWidth = 0.5
            humidityLabelLayer.cornerRadius = humidityLabelLayer.frame.height / 2
            humidityLabelLayer.fontSize = fontSize
            humidityLabelLayer.string = humidityString
            dataLayer.addSublayer(humidityLabelLayer)
        }
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
