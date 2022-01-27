//
//  CurrentWeatherViewModel.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

enum DownloadError: Error {
    case invalidURLError
    case urlSessionError
    case httpError
    case invalidDataError
}

protocol ViewModelDelegate: AnyObject {
    func fetchCompleted(_ indexPaths: [IndexPath]?)
    func fetchFailed(error: APIResponseError)
}

final class CurrentWeatherViewModel {
    
    // MARK: - Property
    
    weak var delegate: ViewModelDelegate?
    
    private let client: OpenWeatherAPIClient = OpenWeatherAPIClient()
    
    var isFetchInProgress: Bool {
        return supportingCities.count != currentWeather.count
    }
    
    var supportingCities: [City] = []
    var currentWeather: [String: CurrentWeatherResponse] = [:]
    var iconCache: NSCache<NSString, UIImage> = NSCache()
    
    // MARK: - Initializer
    
    init() {
        guard let filePath = Bundle.main.path(forResource: "supporting-city-list", ofType: "json"),
                let fileData = FileManager.default.contents(atPath: filePath) else {
            print("Fail to get path or data")
            return
        }
        guard let json: SupportingCityList = try? JSONDecoder().decode(SupportingCityList.self, from: fileData) else {
            print("Fail to decode json data")
            return
        }
        
        print("file read fin")
        
        supportingCities = json.data
    }
    
    // MARK: - Deinitializer
    
    deinit {
        supportingCities.removeAll()
    }
    
    // MARK: -
    
    func fetchCurrentWeathers() {
        print(#function)
        for cityIndex in 0..<supportingCities.count {
            client.fetchCurrentWeatherData(city: Int(supportingCities[cityIndex].id), unit: "metric", language: "kr") { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        print("failure: \(error.localizedDescription)")
                        // 에러 처리
                        self.delegate?.fetchFailed(error: error)
                    }
                case .success(let data):
                    self.currentWeather[String(self.supportingCities[cityIndex].id)] = data
                    
                    DispatchQueue.main.async {
                        self.delegate?.fetchCompleted([IndexPath(row: cityIndex, section: 0)])
                    }
                }
            }
        }
    }
    
}
