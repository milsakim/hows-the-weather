//
//  DetailedWeatherViewControllerSetup.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension DetailedWeatherViewController {
    
    // MARK: - Navigation Setup
    
    func setUpNavigation() {
        guard navigationController != nil else {
            return
        }
        
        // back button title 삭제
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - Table View Setup
    
    func setUpTableView() {
        guard tableView != nil else {
            return
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
}
