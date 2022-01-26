//
//  DetailedWeatherViewControllerSetup.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension DetailedWeatherViewController {
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
}
