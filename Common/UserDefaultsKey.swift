//
//  UserDefaultsKey.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/27.
//

import Foundation

struct UserDefaultsKey {
    static let sortingCriterion = "SortingCritrion"
    static let isAscending = "IsAcsending"
    static let unit = "MeasurementUnit"
}

enum SortingCriterion: String {
    case name = "name"
    case temperature = "temperature"
    case distance = "distance"
}

enum MeasurementUnit: String {
    case celsius = "metric"
    case fahrenheit = "imperial"
}

enum Language: String {
    case english = "en"
    case korean = "kr"
}
