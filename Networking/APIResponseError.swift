//
//  APIResponseError.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import Foundation

enum APIResponseError: Error {
    case url
    case network
    case decoding
    
    var reason: String {
      switch self {
      case .url:
          return "An error occurred while creating URL"
      case .network:
        return "An error occurred while fetching data"
      case .decoding:
        return "An error occurred while decoding data"
      }
    }
}
