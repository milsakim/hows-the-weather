//
//  OpenWeatherAPIClient.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

final class OpenWeatherAPIClient {
    
    private let baseURLString: String = "https://api.openweathermap.org/data/2.5/weather?"
    private let appID: String = "35ec455f68e67138f01a758d471cf357"
    
    func fetchCurrentWeatherData(city id: Int, unit: String, language: String, completion handler: @escaping (Result<CurrentWeatherResponse, APIResponseError>) -> Void) {
        let urlString = baseURLString + "appID=\(appID)" + "&" + "id=\(id)" + "&" + "units=\(unit)" + "&" + "lang=\(language)"
        guard let url: URL = URL(string: urlString) else {
            print("Fail to create URL: \(urlString)")
            return
        }
        
        let urlRequest: URLRequest = URLRequest(url: url)
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
            guard let httpResponse: HTTPURLResponse = urlResponse as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                if let data = data {
                    if let decodedData = try? JSONDecoder().decode(ErrorMessage.self, from: data) {
                        print(decodedData)
                    }
                }
                handler(Result.failure(.network))
                return
            }
            guard let data = data else {
                handler(Result.failure(.network))
                return
            }
            guard let decodedData: CurrentWeatherResponse = try? JSONDecoder().decode(CurrentWeatherResponse.self, from: data) else {
                handler(.failure(.decoding))
                return
            }
            
            handler(.success(decodedData))
        }
        task.resume()
    }

}
