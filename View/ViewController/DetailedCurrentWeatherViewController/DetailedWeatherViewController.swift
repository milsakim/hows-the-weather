//
//  DetailedWeatherViewController.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

class DetailedWeatherViewController: UIViewController {
    
    // MARK: - Property
    
    var city: City?
    var currentWeather: CurrentWeatherResponse?
    var iconImage: UIImage?
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Deinitializer
    
    deinit {
        print("--- DetailedWeatherViewController deinit ---")
    }

    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    private func commonInit() {
        setUpNavigation()
        setUpTableView()
    }

}
