//
//  ForecastViewController.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

class ForecastViewController: UIViewController {

    @IBOutlet weak var lineGraphView: WeatherGraphView!
    
    var viewModel: ForecastViewModel?
    var cityID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    private func commonInit() {
        setupViewModel()
    }
    
}

extension ForecastViewController: ViewModelDelegate {
    
    func fetchCompleted(for indexPaths: [IndexPath]?) {
        print(#function)
        lineGraphView.data = viewModel?.graphPointEntryData
    }
    
    func allSupportedCitiesAreFetched() {
        print(#function)
    }
    
    func fetchFailed(error: APIResponseError) {
        print("fetch failed")
    }
    
}
