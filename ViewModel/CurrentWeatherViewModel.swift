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
    /*
    var fetchedCount: Int = 0 {
        didSet {
            if fetchedCount == supportingCities.count {
                delegate?.allSupportedCitiesAreFetched()
            }
        }
    }
    */
    private let client: OpenWeatherAPIClient = OpenWeatherAPIClient()
    
    var isFetchInProgress: Bool = false {
        didSet {
           print("--- isFetchInProgress: \(isFetchInProgress) ---")
        }
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
        
        print("file read fin: \(json.data.count)")
        
        supportingCities = json.data
        sortSupportingCityList()
    }
    
    // MARK: - Deinitializer
    
    deinit {
        print("--- CurrentWeatherViewModel deinit ---")
        supportingCities.removeAll()
    }
    
    // MARK: -
    
    func fetchCurrentWeathers() {
        print("--- \(#function) ---")
        
        guard !isFetchInProgress else {
            print("--- \(#function): fetch is on progress ---")
            return
        }
        
        delegate?.fetchStarted()
        
        // startIndex..<endIndex에 해당하는 도시의 날씨 정보를 fetch
        let endIndex: Int = (startIndex + loadSize) <= supportingCities.count ? startIndex + loadSize : supportingCities.count
        
        isFetchInProgress = true
        
        client.fetchCurrentWeatherData(cities: supportingCities[startIndex..<endIndex].compactMap({ $0.id }), unit: "metric", language: "kr", completion: { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    print("failure: \(error.localizedDescription)")
                    // 에러 처리
                    self.delegate?.fetchFailed(error: error)
                }
            case .success(let data):
                self.currentWeather[String(data.id)] = data
            }
        }, finishHandler: {
            self.isFetchInProgress = false
            self.delegate?.fetchCompleted(for: (self.startIndex..<endIndex).map({ IndexPath(row: $0, section: 0) }), data: self.supportingCities[self.startIndex..<endIndex].map({ String($0.id) }))
            self.startIndex = endIndex
        })
    }
    
    func clear() {
        print("--- \(#function) ---")
        startIndex = 0
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
        
        if (delegate?.cityIDs.count ?? -1) == supportingCities.count {
            delegate?.cityIDs = supportingCities.map({ String($0.id) })
        }
    }
    
}
