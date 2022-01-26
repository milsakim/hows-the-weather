//
//  APIResponse.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import Foundation

struct CurrentWeatherResponse: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let name: String
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Wind: Codable {
    let speed: Double
    let deg: Double
}

struct ErrorMessage: Codable {
    let cod: String
    let message: String
}