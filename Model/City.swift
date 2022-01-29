//
//  City.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import Foundation

struct SupportingCityList: Codable {
    let data: [City]
}

struct City: Codable {
    let id: Int
    let name: String
    let kr_name: String
    let state: String
    let country: String
    let coord: Coordinate
}

struct Coordinate: Codable {
    let lon: Double
    let lat: Double
}
