//
//  CurrentWeatherViewModel.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

protocol CurrentWeatherViewModelDelegate: AnyObject {
    
    var cityList: [City] { get set }
    func fetchStarted()
    func weatherDataFragmentFetched(for indexPaths: [IndexPath]?, data: [City]?)
    func allWeatherDataFetched()
    func fetchFailed(error: APIResponseError)
    
}

final class CurrentWeatherViewModel {
    
    // MARK: - Property
    
    weak var delegate: CurrentWeatherViewModelDelegate?
    
    private let client: OpenWeatherAPIClient = OpenWeatherAPIClient()
    private var availableCityList: [City] = []
    private let fragmentSize: Int = 10
    
    var currentWeather: [String: CurrentWeatherResponse] = [:]
    var iconCache: NSCache<NSString, UIImage> = NSCache()
    
    var startIndex: Int = 0 {
        didSet {
            print("--- startIndex: \(startIndex) ---")
            if startIndex != 0, startIndex >= availableCityList.count {
                delegate?.allWeatherDataFetched()
            }
        }
    }
    
    var isFetchInProgress: Bool = false {
        didSet {
            print("--- isFetchInProgress: \(isFetchInProgress) ---")
            delegate?.fetchStarted()
        }
    }
    
    var isReadingJSONFailed: Bool = false
    
    var availableCityListCount: Int {
        availableCityList.count
    }
    
    // MARK: - Initialization
    
    init() {
        //        readJSONData()
    }
    
    // MARK: - Deinitialization
    
    deinit {
        delegate = nil
        availableCityList.removeAll()
        currentWeather.removeAll()
        iconCache.removeAllObjects()
        
        print("--- CurrentWeatherViewModel deinit ---")
    }
    
    // MARK: - Common Initialization
    
    func readJSONData() {
        guard let filePath = Bundle.main.path(forResource: "supporting-city-list", ofType: "json"),
              let fileData = FileManager.default.contents(atPath: filePath) else {
                  isReadingJSONFailed = true
                  
                  if delegate != nil {
                      delegate?.fetchFailed(error: .decoding)
                  }
                  print("--- Fail to get path or data ---")
                  return
              }
        
        guard let json: SupportingCityList = try? JSONDecoder().decode(SupportingCityList.self, from: fileData) else {
            isReadingJSONFailed = true
            
            if delegate != nil {
                delegate?.fetchFailed(error: .decoding)
            }
            print("--- Fail to decode json data ---")
            return
        }
        
        print("--- file read fin: \(json.data.count) ---")
        
        // 도시 이름 기준 사전순 정렬
        switch PreferredLocalization(rawValue: Bundle.main.preferredLocalizations[0]) {
        case .english:
            availableCityList = json.data.sorted(by: { $0.name < $1.name })
        default:
            availableCityList = json.data.sorted(by: { $0.kr_name < $1.kr_name })
        }
        
        isReadingJSONFailed = false
    }
    
}

extension CurrentWeatherViewModel {
    
    // MARK: - Data Fetching
    
    func fetchCurrentWeatherData() {
        print("--- CurrentWeatherViewModel \(#function) called: \(startIndex) ---")
        guard !isReadingJSONFailed else {
            delegate?.fetchFailed(error: .decoding)
            return
        }
        
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        let endIndex: Int = (startIndex + fragmentSize) <= availableCityList.count ? startIndex + fragmentSize : availableCityList.count
        let cityIDsToFetch: [Int] = availableCityList[startIndex..<endIndex].map({ $0.id })
        
        let unit: String = UserDefaults.standard.object(forKey: UserDefaultsKey.unit) as? String ?? MeasurementUnit.celsius.rawValue
        
        let language: String
        switch PreferredLocalization(rawValue: Bundle.main.preferredLocalizations[0]) {
        case .english:
            language = Language.english.rawValue
        default:
            language = Language.korean.rawValue
        }
        
        client.fetchCurrentWeatherData(cityIDs: cityIDsToFetch, unit: unit, language: language) { result in
            switch result {
            case .success(let weatherData):
                print("--- \(#function) success: \(weatherData.reduce(into: "", { $0 += $1.name + " " }))")
                for weatherDatum in weatherData {
                    self.currentWeather[String(weatherDatum.id)] = weatherDatum
                }
                self.isFetchInProgress = false
                self.delegate?.weatherDataFragmentFetched(for: (self.startIndex..<endIndex).map({ IndexPath(row: $0, section: 0)}), data: Array(self.availableCityList[self.startIndex..<endIndex]))
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
        print("--- CurrentWeatherViewModel \(#function) called ---")
        startIndex = 0
        currentWeather.removeAll()
        iconCache.removeAllObjects()
    }
    
    // MARK: -
    
    func sortSupportingCityList() {
        guard let delegate = delegate else {
            return
        }
        
        let criterionString: String = UserDefaults.standard.object(forKey: UserDefaultsKey.sortingCriterion) as? String ?? SortingCriterion.name.rawValue
        let sortingCriterion: SortingCriterion = SortingCriterion(rawValue: criterionString) ?? .name
        let isAcending: Bool = UserDefaults.standard.object(forKey: UserDefaultsKey.isAscending) as? Bool ?? true
        
        
        switch sortingCriterion {
        case .name:
            switch PreferredLocalization(rawValue: Bundle.main.preferredLocalizations[0]) {
            case .english:
                if isAcending {
                    delegate.cityList.sort { $0.name < $1.name }
                }
                else {
                    delegate.cityList.sort { $0.name > $1.name }
                }
            default:
                if isAcending {
                    delegate.cityList.sort { $0.kr_name < $1.kr_name }
                }
                else {
                    delegate.cityList.sort { $0.kr_name > $1.kr_name }
                }
            }
        case .temperature:
            if isAcending {
                delegate.cityList.sort { currentWeather[String($0.id)]!.main.temp < currentWeather[String($1.id)]!.main.temp }
            }
            else {
                delegate.cityList.sort { currentWeather[String($0.id)]!.main.temp > currentWeather[String($1.id)]!.main.temp }
            }
        case .distance:
            if isAcending {
                // 거리 오름차순 정렬
            }
            else {
                // 거리 내림차순 정렬
            }
        }
    }
    
}
