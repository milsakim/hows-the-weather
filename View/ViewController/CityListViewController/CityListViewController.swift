//
//  CityListViewController.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

class CityListViewController: UIViewController {

    // MARK: - Property
    
    @IBOutlet weak var tableView: UITableView!
    
    // table view의 header
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var ascendingButton: UIButton!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        OpenWeatherAPIClient().fetchCurrentWeatherData(city: "", unit: "metric", language: "kr")
    }
    
    private func commonInit() {
        setupTableView()
    }
    
}
