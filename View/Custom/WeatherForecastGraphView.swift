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

class WeatherForecastGraphView: UIView {
    
    // MARK: - Property
    
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
    
    private var graphLayer: CALayer?
    private var maxTempGraphLayer: CALayer?
    private var minTempGraphLayer: CALayer?
    private var humidityGraphLayer: CALayer?
    private var verticalLinesLayer: CALayer?
    
    private let scrollView: UIScrollView = UIScrollView()
    private let contentView: UIView = UIView()
    
    private var minTempDataPoints: [CGPoint]?
    private var maxTempDataPoints: [CGPoint]?
    private var humidityDataPoints: [CGPoint]?
    
    private var minTempColor: CGColor {
        UIColor(named: "min-temp-graph-color")?.cgColor ?? UIColor.blue.cgColor
    }
    
    private var maxTempColor: CGColor {
        UIColor(named: "max-temp-graph-color")?.cgColor ?? UIColor.red.cgColor
    }
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        graphLayer = CALayer()
        verticalLinesLayer = CALayer()
        maxTempGraphLayer = CALayer()
        minTempGraphLayer = CALayer()
        humidityGraphLayer = CALayer()
        
        super.init(frame: frame)
        
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        graphLayer = CALayer()
        verticalLinesLayer = CALayer()
        maxTempGraphLayer = CALayer()
        minTempGraphLayer = CALayer()
        humidityGraphLayer = CALayer()
        
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    // MARK: - Deinitialization
    
    deinit {
        maxTempGraphLayer?.removeFromSuperlayer()
        minTempGraphLayer?.removeFromSuperlayer()
        humidityGraphLayer?.removeFromSuperlayer()
        verticalLinesLayer?.removeFromSuperlayer()
        graphLayer?.removeFromSuperlayer()
        
        if humidityDataPoints != nil {
            humidityDataPoints?.removeAll()
            humidityDataPoints = nil
        }
        
        if minTempDataPoints != nil {
            minTempDataPoints?.removeAll()
            minTempDataPoints = nil
        }
        
        if maxTempDataPoints != nil {
            maxTempDataPoints?.removeAll()
            maxTempDataPoints = nil
        }
        
        print("--- WeatherGraphView deinit ---")
    }
    
    // MARK: - Laying Out Subviews
    
    override func layoutSubviews() {
        print("--- WeatherGraphView \(#function) called ---")
        removeGraphLayers()
        
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        scrollView.setZoomScale(1.0, animated: true)
        
        guard let data = data else {
            return
        }
        
        guard let graphLayer = graphLayer,
              let verticalLinesLayer = verticalLinesLayer,
              let humidityGraphLayer = humidityGraphLayer,
              let minTempGraphLayer = minTempGraphLayer,
              let maxTempGraphLayer = maxTempGraphLayer else {
                  return
              }
        
        // self.frame에 맞춰 view와 layer frame 설정
        let scrollViewContentSize: CGSize = CGSize(width: CGFloat(data.count) * lineGap + leadingSpace + trailingSpace, height: self.frame.size.height)
        
        contentView.frame = CGRect(origin: .zero, size: scrollViewContentSize)
        
        graphLayer.frame = contentView.frame
        
        verticalLinesLayer.frame = graphLayer.frame
        humidityGraphLayer.frame = graphLayer.frame
        minTempGraphLayer.frame = graphLayer.frame
        maxTempGraphLayer.frame = graphLayer.frame
        
        scrollView.contentSize = scrollViewContentSize
        
        
        // self.frame에 맞게 데이터 위치 계산
        let minTempData: [Double] = data.map({ $0.minTempValue })
        let maxTempData: [Double] = data.map({ $0.maxTempValue })
        
        let tempRange: (Double?, Double?) = (minTempData.min(), maxTempData.max())
        
        let humidityData: [Double] = data.map({ $0.humidityValue })
        
        let humidityRange: (Double?, Double?) = (humidityData.min(), humidityData.max())
        
        minTempDataPoints = convertDataEntriesToPoints(data: minTempData, range: tempRange)
        maxTempDataPoints = convertDataEntriesToPoints(data: maxTempData, range: tempRange)
        humidityDataPoints = convertDataEntriesToPoints(data: humidityData, range: humidityRange)
        
        drawForecastGraph()
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        print("--- WeatherGraphView \(#function) called ---")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        print("--- WeatherGraphView \(#function) called ---")
    }
    
    // MARK: - Initial Setup
    
    private func setupView() {
        guard let graphLayer = graphLayer else {
            return
        }
        
        guard let vericalLinesLayer = verticalLinesLayer, let minTempGraphLayer = minTempGraphLayer, let maxTempGraphLayer = maxTempGraphLayer, let humidityGraphLayer = humidityGraphLayer else {
            return
        }
        
        graphLayer.addSublayer(vericalLinesLayer)
        graphLayer.addSublayer(humidityGraphLayer)
        graphLayer.addSublayer(minTempGraphLayer)
        graphLayer.addSublayer(maxTempGraphLayer)
        
        contentView.layer.addSublayer(graphLayer)
        
        scrollView.addSubview(contentView)
        
        self.addSubview(scrollView)
        
        // layer들의 background 색상 투명으로 지정
        graphLayer.backgroundColor = UIColor.clear.cgColor
        vericalLinesLayer.backgroundColor = UIColor.clear.cgColor
        humidityGraphLayer.backgroundColor = UIColor.clear.cgColor
        minTempGraphLayer.backgroundColor = UIColor.clear.cgColor
        maxTempGraphLayer.backgroundColor = UIColor.clear.cgColor
        
        setupScrollView()
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 1.0
    }
    
}

extension WeatherForecastGraphView {
    
    private func removeGraphLayers() {
        // vertical line layer의 sublayer 삭제
        if verticalLinesLayer != nil {
            verticalLinesLayer?.sublayers?.forEach({ $0.removeFromSuperlayer() })
        }
        
        // humidity graph layer
        if humidityGraphLayer != nil {
            humidityGraphLayer?.sublayers?.forEach({ $0.removeFromSuperlayer() })
        }
        
        // min temp graph layer
        if minTempGraphLayer != nil {
            minTempGraphLayer?.sublayers?.forEach({ $0.removeFromSuperlayer() })
        }
        
        // max temp graph layer
        if maxTempGraphLayer != nil {
            maxTempGraphLayer?.sublayers?.forEach({ $0.removeFromSuperlayer() })
        }
    }
    
    // MARK: - Drawing Weather Forecast Graph
    
    private func drawForecastGraph() {
        drawVerticalLines()
        drawGraph()
        drawDots()
        drawDataLabels()
        drawDateLabels()
    }
    
    private func drawGraph() {
        // 습도 그래프
        if let humidityGraphLayer = humidityGraphLayer,
           let humidityDataPoints = humidityDataPoints,
           humidityDataPoints.count > 0,
           let path = createPath(from: humidityDataPoints) {
            
            let humidityGraph = CAShapeLayer()
            humidityGraph.path = path.cgPath
            humidityGraph.lineWidth = 3.0
            humidityGraph.strokeColor = UIColor(named: "humidity-graph-color")?.cgColor
            humidityGraph.fillColor = UIColor.clear.cgColor
            
            humidityGraphLayer.addSublayer(humidityGraph)
        }
        
        // 최저 온도 그래프
        if let minTempGraphLayer = minTempGraphLayer,
           let minTempDataPoints = minTempDataPoints,
           minTempDataPoints.count > 0,
           let path = createPath(from: minTempDataPoints) {
            
            let minTempGraph = CAShapeLayer()
            minTempGraph.path = path.cgPath
            minTempGraph.lineWidth = 3.0
            minTempGraph.strokeColor = minTempColor
            minTempGraph.fillColor = UIColor.clear.cgColor
            
            minTempGraphLayer.addSublayer(minTempGraph)
        }
        
        // 최고 온도 그래프
        if let maxTempGraphLayer = maxTempGraphLayer,
           let maxTempDataPoints = maxTempDataPoints,
           maxTempDataPoints.count > 0,
           let path = createPath(from: maxTempDataPoints) {
            
            let maxTempGraph = CAShapeLayer()
            maxTempGraph.path = path.cgPath
            maxTempGraph.lineWidth = 3.0
            maxTempGraph.strokeColor = maxTempColor
            maxTempGraph.fillColor = UIColor.clear.cgColor
            
            maxTempGraphLayer.addSublayer(maxTempGraph)
        }
    }
    
    private func drawDataLabels() {
        guard let data = data,
              let minTempDataPoints = minTempDataPoints,
              let maxTempDataPoints = maxTempDataPoints,
              let humidityDataPoints = humidityDataPoints else {
                  return
              }
        
        guard let humidityGraphLayer = humidityGraphLayer,
              let minTempGraphLayer = minTempGraphLayer,
              let maxTempGraphLayer = maxTempGraphLayer else {
                  return
              }
        
        let labelLayerHeight: CGFloat = 15
        let fontSize: CGFloat = 11
        let widthPadding: CGFloat = 4.0
        let gap: CGFloat = 4.0
        let backgroundColor: CGColor? = UIColor(named: "graph-label-background-color")?.cgColor ?? UIColor.lightGray.cgColor.copy(alpha: 0.5)
        
        for dataIndex in 0..<data.count {
            // humidity label
            let humidityString: String = "\(data[dataIndex].humidityValue)%"
            let humidityStringWidth: CGFloat = (humidityString as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width
            let humidityLabelLayerWidth: CGFloat = humidityStringWidth + widthPadding
            let humidityLabelLayer: CATextLayer = CATextLayer()
            humidityLabelLayer.frame = CGRect(x: humidityDataPoints[dataIndex].x - (humidityLabelLayerWidth / 2), y: humidityDataPoints[dataIndex].y - labelLayerHeight - gap, width: humidityLabelLayerWidth, height: labelLayerHeight)
            humidityLabelLayer.alignmentMode = .center
            humidityLabelLayer.contentsScale = UIScreen.main.scale
            humidityLabelLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            humidityLabelLayer.foregroundColor = UIColor(named: "humidity-graph-color")?.cgColor ?? UIColor.black.cgColor
            humidityLabelLayer.backgroundColor = backgroundColor
            humidityLabelLayer.borderColor = UIColor.gray.cgColor
            humidityLabelLayer.borderWidth = 0.5
            humidityLabelLayer.cornerRadius = humidityLabelLayer.frame.height / 2
            humidityLabelLayer.fontSize = fontSize
            humidityLabelLayer.string = humidityString
            
            humidityGraphLayer.addSublayer(humidityLabelLayer)
            
            // min temp label
            let minTempString: String = "\(data[dataIndex].minTempValue)℃"
            let minTempStringWidth: CGFloat = (minTempString as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width
            let minTempLabelLayerWidth: CGFloat = minTempStringWidth + widthPadding
            let minTempLabelLayer: CATextLayer = CATextLayer()
            minTempLabelLayer.frame = CGRect(x: minTempDataPoints[dataIndex].x - (minTempLabelLayerWidth / 2), y: minTempDataPoints[dataIndex].y - labelLayerHeight - gap, width: minTempLabelLayerWidth, height: labelLayerHeight)
            minTempLabelLayer.backgroundColor = backgroundColor
            minTempLabelLayer.borderColor = UIColor.gray.cgColor
            minTempLabelLayer.borderWidth = 0.5
            minTempLabelLayer.cornerRadius = labelLayerHeight / 2
            minTempLabelLayer.alignmentMode = .center
            minTempLabelLayer.contentsScale = UIScreen.main.scale
            minTempLabelLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            minTempLabelLayer.foregroundColor = minTempColor
            minTempLabelLayer.fontSize = fontSize
            minTempLabelLayer.string = minTempString
            
            minTempGraphLayer.addSublayer(minTempLabelLayer)
            
            // max temp label
            let maxTempString: String = "\(data[dataIndex].maxTempValue)℃"
            let maxTempStringWidth: CGFloat = (maxTempString as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width
            let maxTempLabelLayerWidth: CGFloat = maxTempStringWidth + widthPadding
            let maxTempLabelLayer: CATextLayer = CATextLayer()
            maxTempLabelLayer.frame = CGRect(x: maxTempDataPoints[dataIndex].x - (minTempLabelLayerWidth / 2), y: maxTempDataPoints[dataIndex].y - labelLayerHeight - gap, width: maxTempLabelLayerWidth, height: labelLayerHeight)
            maxTempLabelLayer.backgroundColor = backgroundColor
            maxTempLabelLayer.cornerRadius = labelLayerHeight / 2
            maxTempLabelLayer.borderColor = UIColor.gray.cgColor
            maxTempLabelLayer.borderWidth = 0.5
            maxTempLabelLayer.alignmentMode = .center
            maxTempLabelLayer.contentsScale = UIScreen.main.scale
            maxTempLabelLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            maxTempLabelLayer.foregroundColor = maxTempColor
            maxTempLabelLayer.fontSize = fontSize
            maxTempLabelLayer.string = maxTempString
            maxTempGraphLayer.addSublayer(maxTempLabelLayer)
        }
    }
    
    private func drawDots() {
        let dotRadius: CGFloat = 4
        
        // humidity graph
        if let humidityGraphLayer = humidityGraphLayer, let humidityDataPoints = humidityDataPoints {
            let path: UIBezierPath = UIBezierPath()
            
            for humidityDataPoint in humidityDataPoints {
                path.move(to: humidityDataPoint)
                path.addArc(withCenter: humidityDataPoint, radius: dotRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
                path.fill()
            }
            
            let shapeLayer: CAShapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = UIColor(named: "humidity-graph-color")?.cgColor ?? UIColor.black.cgColor
            
            humidityGraphLayer.addSublayer(shapeLayer)
        }
        
        // min temp graph
        if let minTempGraphLayer = minTempGraphLayer, let minTempDataPoints = minTempDataPoints {
            let path: UIBezierPath = UIBezierPath()
            
            for minTempDataPoint in minTempDataPoints {
                path.move(to: minTempDataPoint)
                path.addArc(withCenter: minTempDataPoint, radius: dotRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
                path.fill()
            }
            
            let shapeLayer: CAShapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = minTempColor
            
            minTempGraphLayer.addSublayer(shapeLayer)
        }
        
        // max temp graph
        if let maxTempGraphLayer = maxTempGraphLayer, let maxTempDataPoints = maxTempDataPoints {
            let path: UIBezierPath = UIBezierPath()
            
            for maxTempDataPoint in maxTempDataPoints {
                path.move(to: maxTempDataPoint)
                path.addArc(withCenter: maxTempDataPoint, radius: dotRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
                path.fill()
            }
            
            let shapeLayer: CAShapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = maxTempColor
            
            maxTempGraphLayer.addSublayer(shapeLayer)
        }
    }
    
    private func drawVerticalLines() {
        guard let verticalLinesLayer = verticalLinesLayer,
              let data = data else {
                  return
              }
        
        let path: UIBezierPath = UIBezierPath()
        
        for index in 0..<(data.count - 1) {
            path.move(to: CGPoint(x: lineGap * CGFloat(index + 1) + leadingSpace, y: topSpace))
            path.addLine(to: CGPoint(x: lineGap * CGFloat(index + 1) + leadingSpace, y: verticalLinesLayer.frame.size.height))
        }
        
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor
        shapeLayer.lineDashPattern = [4, 4]
        shapeLayer.lineWidth = 0.8
        
        verticalLinesLayer.addSublayer(shapeLayer)
    }
    
    private func drawDateLabels() {
        print("--- \(#function) called ---")
        guard let data = data, data.count > 0, let verticalLinesLayer = verticalLinesLayer else {
            print("--- \(#function) guard exit ---")
            return
        }
        
        for i in 0..<data.count {
            let textLayer: CATextLayer = CATextLayer()
            textLayer.frame = CGRect(x: lineGap * CGFloat(i) + leadingSpace, y: verticalLinesLayer.frame.size.height - bottomSpace/2 - 8, width: lineGap, height: 30)
            textLayer.foregroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor
            textLayer.backgroundColor = UIColor.clear.cgColor
            textLayer.alignmentMode = .center
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            textLayer.fontSize = 11
            
            let date: Date = Date(timeIntervalSince1970: TimeInterval(data[i].timeStamp))
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd\nhh:mm a"
            textLayer.string = dateFormatter.string(from: date)
            
            verticalLinesLayer.addSublayer(textLayer)
        }
    }
    
    // MARK: - Helper Method
    
    private func convertDataEntriesToPoints(data: [Double], range: (min: Double?, max: Double?)) -> [CGPoint] {
        if let graphLayer = graphLayer, let minValue: Double = range.min, let maxValue: Double = range.max {
            var result: [CGPoint] = []
            let ratio: CGFloat = (graphLayer.frame.height - bottomSpace - topSpace) / CGFloat(maxValue - minValue)
            
            for index in 0..<data.count {
                let xPos: CGFloat = CGFloat(index) * lineGap + lineGap / 2 + leadingSpace
                let yPos: CGFloat = (graphLayer.frame.height - bottomSpace - topSpace) - (data[index] - minValue) * ratio + topSpace
                result.append(CGPoint(x: xPos, y: yPos))
            }
            
            return result
        }
        
        return []
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
    
}

extension WeatherForecastGraphView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        print(#function)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print(#function)
        
        let scrollViewWidth: CGFloat = scrollView.bounds.width
        let scrollViewHeight: CGFloat = scrollView.bounds.height
        
        let contentViewWidth: CGFloat = contentView.frame.width
        let contentViewHeight: CGFloat = contentView.frame.height
        
        var contentViewFrame: CGRect = contentView.frame
        
        if contentViewWidth < scrollViewWidth {
            contentViewFrame.origin.x = (scrollViewWidth - contentViewWidth) / 2
        }
        else {
            contentViewFrame.origin.x = 0
        }
        
        if contentViewHeight < scrollViewHeight {
            contentViewFrame.origin.y = (scrollViewHeight - contentViewHeight) / 2
        }
        else {
            contentViewFrame.origin.y = 0
        }
        
        contentView.frame = contentViewFrame
    }
    
}
