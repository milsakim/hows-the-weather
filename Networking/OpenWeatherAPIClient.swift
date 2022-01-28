//
//  OpenWeatherAPIClient.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

final class OpenWeatherAPIClient {
    
    private let baseURLString: String = "https://api.openweathermap.org/data/2.5/weather?"
    private let forecastBaseURLString: String = "https://api.openweathermap.org/data/2.5/forecast?"
    
    private let appID: String = "35ec455f68e67138f01a758d471cf357"

    func fetchCurrentWeatherData(cityIDs: [Int], unit: String, language: String, completion handler: @escaping (Result<[CurrentWeatherResponse], APIResponseError>) -> Void) {
        print("--- \(#function) called: \(cityIDs.reduce(into: "", { $0 += "\($1) " }))---")
        
        let dispatchGroup: DispatchGroup = DispatchGroup()
        var tasks: [URLSessionDataTask] = []
        var fetchError: APIResponseError?
        var fetchedWeatherData: [CurrentWeatherResponse] = []
        
        for cityID in cityIDs {
            let urlString = baseURLString + "appID=\(appID)" + "&" + "id=\(cityID)" + "&" + "units=\(unit)" + "&" + "lang=\(language)"
            guard let url: URL = URL(string: urlString) else {
                fetchError = .url
                return
            }
            
            dispatchGroup.enter()
            let task: URLSessionDataTask = URLSession.shared.dataTask(with: url) { data, urlResponse, error in
                guard let httpResponse: HTTPURLResponse = urlResponse as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                    print("--- error ---")
                    fetchError = .network
                    dispatchGroup.leave()
                    return
                }
                
                guard let data = data else {
                    fetchError = .network
                    dispatchGroup.leave()
                    return
                }
                
                guard let decodedData: CurrentWeatherResponse = try? JSONDecoder().decode(CurrentWeatherResponse.self, from: data) else {
                    fetchError = .network
                    dispatchGroup.leave()
                    return
                }
                
                fetchedWeatherData.append(decodedData)
                dispatchGroup.leave()
            }
            tasks.append(task)
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            print("--- DispatchGroup completed ---")
            if let fetchError = fetchError {
                handler(.failure(fetchError))
            }
            else {
                handler(.success(fetchedWeatherData))
            }
        }
        
        tasks.forEach({ $0.resume() })
    }

    func fetchForecastData(city id: Int, ompletion handler: @escaping (Result<ForecastResponse, APIResponseError>) -> Void) {
        let urlString = forecastBaseURLString + "appID=\(appID)" + "&" + "id=\(id)" + "&" + "units=metric" + "&" + "lang=kr"
        guard let url: URL = URL(string: urlString) else {
            print("--- Fail to create URL: \(urlString) ---")
            return
        }
        
        let urlRequest: URLRequest = URLRequest(url: url)
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
            guard let httpResponse: HTTPURLResponse = urlResponse as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                if let data = data {
                    if let decodedData = try? JSONDecoder().decode(ErrorMessage.self, from: data) {
                        print("--- \(decodedData) ---")
                    }
                }
                handler(Result.failure(.network))
                return
            }
            guard let data = data else {
                handler(Result.failure(.network))
                return
            }
            guard let decodedData: ForecastResponse = try? JSONDecoder().decode(ForecastResponse.self, from: data) else {
                handler(.failure(.decoding))
                return
            }
            handler(.success(decodedData))
        }
        task.resume()
    }

}
