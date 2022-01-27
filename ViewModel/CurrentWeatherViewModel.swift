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
    func fetchStarted()
    func fetchCompleted(for indexPaths: [IndexPath]?)
    func allSupportedCitiesAreFetched()
    func fetchFailed(error: APIResponseError)
}

final class CurrentWeatherViewModel {
    
    // MARK: - Property
    
    weak var delegate: ViewModelDelegate?
    
    private let loadSize: Int = 20
    private var startIndex: Int = 0 {
        didSet {
            if startIndex == supportingCities.count {
                DispatchQueue.main.async {
                    self.delegate?.allSupportedCitiesAreFetched()
                }
                isFetchInProgress = false
            }
            
            if startIndex % loadSize == 0 {
                isFetchInProgress = false
            }
        }
    }
    var targetCount: Int = 0
    
    private let client: OpenWeatherAPIClient = OpenWeatherAPIClient()
    
    var isFetchInProgress: Bool = false

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
        
        print("file read fin: \(json.data.count)")
        
        supportingCities = json.data
    }
    
    // MARK: - Deinitializer
    
    deinit {
        print("--- CurrentWeatherViewModel deinit ---")
        supportingCities.removeAll()
    }
    
    // MARK: -
    
    func fetchCurrentWeathers() {
        delegate?.fetchStarted()
        
        // startIndex..<endIndex에 해당하는 도시의 날씨 정보를 fetch
        let endIndex: Int = (startIndex + loadSize) < supportingCities.count ? startIndex + loadSize : supportingCities.count
        
        isFetchInProgress = true
        targetCount += (endIndex - startIndex)
        
        for cityIndex in startIndex..<endIndex {
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
                        self.delegate?.fetchCompleted(for: [IndexPath(row: cityIndex, section: 0)])
                    }
                }
                self.startIndex += 1
            }
        }
        
        /*
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
        */
    }
    
    func clear() {
        startIndex = 0
        targetCount = 0
        currentWeather.removeAll()
        iconCache.removeAllObjects()
    }
    
    // MARK: -
    
    func sortSupportingCityList() {
        let criterionString: String = UserDefaults.standard.object(forKey: UserDefaultsKey.sortingCriterion.rawValue) as? String ?? SortingCriterion.name.rawValue
        let sortingCriterion: SortingCriterion = SortingCriterion(rawValue: criterionString) ?? .name
        let isAcending: Bool = UserDefaults.standard.object(forKey: UserDefaultsKey.isAscending.rawValue) as? Bool ?? true
        
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
                
            }
            else {
                
            }
        }
    }
    
}
