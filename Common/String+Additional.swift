//
//  String+Additional.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/30.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, value: self, comment: "")
    }
    
}
