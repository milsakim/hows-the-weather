//
//  UserDefaultsKey.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/27.
//

import Foundation

/*
enum UserDefaultsKey: String {
    case sortingCriterion = "SortingCritrion"
    case isAscending = "IsAcsending"
    case language = "Language"
    case unit = "Unit"
}
*/

struct UserDefaultsKey {
    static let sortingCriterion = "SortingCritrion"
    static let isAscending = "IsAcsending"
    static let language = "Language"
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
