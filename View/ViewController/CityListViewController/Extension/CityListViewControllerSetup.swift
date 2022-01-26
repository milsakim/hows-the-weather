//
//  CityListViewControllerSetup.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension CityListViewController {
    
    func setupTableView() {
        // table view의 data source와 delegate 설정
        tableView.dataSource = self
        tableView.delegate = self
        
        // table view의 header 설정
        tableView.tableHeaderView = headerView
        setupTableHeaderView()
    }
    
    func setupTableHeaderView() {
    }
    
}
