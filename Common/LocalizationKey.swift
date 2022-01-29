//
//  LocalizationKey.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/29.
//

import Foundation

struct LocalizationKey {
    
    // MARK: - CityListViewController
    
    static let cityListViewControllerTitle: String = "Today's Weather"
    
    static let sort: String = "Sort"
    static let cityName: String = "City Name"
    static let temperature: String = "Temperature"
    static let distance: String = "Distance"
    static let ascending: String = "Ascending"
    static let descending: String = "Descending"
    
    static let prefrences: String = "Prefrences"
    static let celsicus: String = "Celsius"
    static let fahrenheit: String = "Fahrenheit"
    
    // MARK: - DetailedWeatherViewController
    
    static let feelsLike: String = "Feels like"
    static let max: String = "Max"
    static let min: String = "Min"
    
    static let todaysDetails: String = "Today's Details"
    static let humidity: String = "Humidity"
    static let pressure: String = "Pressure"
    static let wind: String = "Wind"
    
    static let forecast: String = "Forecast"
    
}

enum PreferredLocalization: String {
    case english = "en"
    case korean = "ko"
}
