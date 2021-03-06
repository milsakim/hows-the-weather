//
//  ForecastViewControllerSetup.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/27.
//

import UIKit

extension ForecastViewController {
    
    // MARK: - View Model Setup
    
    func setUpViewModel() {
        if let cityID = cityID {
            viewModel = ForecastViewModel(city: cityID)
            viewModel?.delegate = self
            viewModel?.fetchForecastData()
        }
    }
    
}
