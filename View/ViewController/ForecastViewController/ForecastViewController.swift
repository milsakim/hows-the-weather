//
//  ForecastViewController.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

class ForecastViewController: UIViewController {

    @IBOutlet weak var lineGraphView: WeatherForecastGraphView!
    
    var viewModel: ForecastViewModel?
    var cityID: Int?
    
    // MARK: - Deinitialization
    
    deinit {
        viewModel = nil
        print("--- ForecastViewController deinit ---")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    // MARK: - Common Initialization
    
    private func commonInit() {
        setUpViewModel()
    }
    
}
