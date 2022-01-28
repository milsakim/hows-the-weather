//
//  ForecastViewModelDelegate.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/29.
//

import Foundation

extension ForecastViewController: ForecastViewModelDelegate {
    
    func fetchCompleted() {
        print("--- \(#function) ---")
        
        guard let viewModel = viewModel else {
            showFetchingFailureAlert()
            return
        }
        
        lineGraphView.data = viewModel.graphPointEntryData
    }

    func fetchFailed(error: APIResponseError) {
        print("--- fetch failed ---")
        showFetchingFailureAlert()
    }
    
}
