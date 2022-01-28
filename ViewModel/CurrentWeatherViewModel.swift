//
//  CurrentWeatherViewModel.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

protocol CurrentWeatherViewModelDelegate: AnyObject {
    var cityIDs: [String] { get set }
    func fetchStarted()
    func fetchCompleted(for indexPaths: [IndexPath]?, data: [String]?)
    func allSupportedCitiesAreFetched()
    func fetchFailed(error: APIResponseError)
}

final class CurrentWeatherViewModel {
    
    // MARK: - Property
    
    weak var delegate: CurrentWeatherViewModelDelegate?
    
    private let loadSize: Int = 9
    
    var startIndex: Int = 0 {
        didSet {
            print("--- startIndex: \(startIndex) ---")
            if startIndex >= supportingCities.count {
                delegate?.allSupportedCitiesAreFetched()
            }
        }
    }

    private let client: OpenWeatherAPIClient = OpenWeatherAPIClient()
    
    var isFetchInProgress: Bool = false {
        didSet {
           print("--- isFetchInProgress: \(isFetchInProgress) ---")
            delegate?.fetchStarted()
        }
    }
//    var isFetchingFailed: Bool = false

    var supportingCities: [City] = []
    var currentWeather: [String: CurrentWeatherResponse] = [:]
    var iconCache: NSCache<NSString, UIImage> = NSCache()
    
    // MARK: - Initializer
    
    init() {
        guard let filePath = Bundle.main.path(forResource: "supporting-city-list", ofType: "json"),
                let fileData = FileManager.default.contents(atPath: filePath) else {
            print("--- Fail to get path or data ---")
            return
        }
        guard let json: SupportingCityList = try? JSONDecoder().decode(SupportingCityList.self, from: fileData) else {
            print("--- Fail to decode json data ---")
            return
        }
        
        print("--- file read fin: \(json.data.count) ---")
        
        supportingCities = json.data
        sortSupportingCityList()
    }
    
    // MARK: - Deinitializer
    
    deinit {
        print("--- CurrentWeatherViewModel deinit ---")
        supportingCities.removeAll()
    }
    
    // MARK: -
    
    func fetchCurrentWeatherData() {
        print("--- \(#function) called: \(startIndex) ---")
        
        if isFetchInProgress { return }
        
        isFetchInProgress = true
        
        let endIndex: Int = (startIndex + loadSize) <= supportingCities.count ? startIndex + loadSize : supportingCities.count
        print("--- endIndex: \(endIndex) ---")
        let cityIDsToFetch: [Int] = supportingCities[startIndex..<endIndex].map({ $0.id })
        client.fetchCurrentWeatherData(cityIDs: cityIDsToFetch, unit: "metric", language: "kr") { result in
            switch result {
            case .success(let weatherData):
                print("--- \(#function) success: \(weatherData.reduce(into: "", { $0 += $1.name + " " }))")
                for weatherDatum in weatherData {
                    self.currentWeather[String(weatherDatum.id)] = weatherDatum
                }
                self.isFetchInProgress = false
                self.delegate?.fetchCompleted(for: (self.startIndex..<endIndex).map({ IndexPath(row: $0, section: 0)}), data: cityIDsToFetch.map({ String($0) }))
                self.startIndex = endIndex
            case .failure(let error):
                print("--- \(#function) fail ---")
                DispatchQueue.main.async {
                    print("--- \(#function) fail block ---")
                    self.delegate?.fetchFailed(error: error)
                }
            }
        }
    }

    func clear() {
        print("--- \(#function) ---")
        startIndex = 0
        currentWeather.removeAll()
        iconCache.removeAllObjects()
//        isFetchingFailed = false
    }
    
    // MARK: -
    
    func sortSupportingCityList() {
        let criterionString: String = UserDefaults.standard.object(forKey: UserDefaultsKey.sortingCriterion) as? String ?? SortingCriterion.name.rawValue
        let sortingCriterion: SortingCriterion = SortingCriterion(rawValue: criterionString) ?? .name
        let isAcending: Bool = UserDefaults.standard.object(forKey: UserDefaultsKey.isAscending) as? Bool ?? true
        
        switch sortingCriterion {
        case .name:
            if isAcending {
                supportingCities.sort { $0.name < $1.name }
            }
            else {
                supportingCities.sort { $0.name > $1.name }
            }
        case .temperature:
            if isAcending {
                supportingCities.sort { currentWeather[String($0.id)]!.main.temp < currentWeather[String($1.id)]!.main.temp }
            }
            else {
                supportingCities.sort { currentWeather[String($0.id)]!.main.temp > currentWeather[String($1.id)]!.main.temp }
            }
        case .distance:
            if isAcending {
                // 거리 오름차순 정렬
            }
            else {
                // 거리 내림차순 정렬
            }
        }
        
        if (delegate?.cityIDs.count ?? -1) == supportingCities.count {
            delegate?.cityIDs = supportingCities.map({ String($0.id) })
        }
    }
    
}
