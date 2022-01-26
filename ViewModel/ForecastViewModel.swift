//
//  ForecastViewModel.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/27.
//

import Foundation

struct ForeCastData {
    let date: Int
    let temperature: Double
    let humidity: Double
}

final class ForecastViewModel {
    
    // MARK: - Property
    
    private let client: OpenWeatherAPIClient
    private let cityID: Int
    private var foreCastData: [ForeCastData] = []
    
    var graphPointEntryData: [PointEntry] {
        foreCastData.compactMap { PointEntry(value: $0.temperature, humidityValue: $0.humidity, label: String($0.date)) }
    }
    
    weak var delegate: ViewModelDelegate?
    
    // MARK: - Initializer
    
    init(city id: Int) {
        client = OpenWeatherAPIClient()
        cityID = id
    }
    
    func fetchForecastData() {
        client.fetchForecastData(city: cityID) { result in
            switch result {
            case .failure(let error):
                self.delegate?.fetchFailed(error: error)
            case .success(let data):
                data.list.forEach {
                    self.foreCastData.append(ForeCastData(date: $0.dt, temperature: ($0.main.temp_min + $0.main.temp_max) / 2, humidity: $0.main.humidity))
                }
                
                DispatchQueue.main.async {
                    self.delegate?.fetchCompleted(nil)
                }
            }
        }
    }
    
}
