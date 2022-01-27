//
//  CityListViewControllerSetup.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension CityListViewController {
    
    func setupNavigation() {
        
    }
    
    func setupTableView() {
        // table view의 data source와 delegate 설정
        tableView.dataSource = self
        tableView.delegate = self
        
        // table view의 header 설정
        tableView.tableHeaderView = headerView
        setupTableHeaderView()
        
        tableView.refreshControl = UIRefreshControl()
    }
    
    func setupTableHeaderView() {
        let sortByCityName: UIAction = UIAction(title: "City Name") { action in
            
        }
        let sortByTemp: UIAction = UIAction(title: "Temperature") { action in
            
        }
        let sortByDistance: UIAction = UIAction(title: "Distance") { action in
            
        }
        let sortingMenu: UIMenu = UIMenu(title: "Sort by", children: [sortByCityName, sortByTemp, sortByDistance])
        sortButton.menu = sortingMenu
        sortButton.showsMenuAsPrimaryAction = true
    }
    
    func setupViewModel() {
        viewModel = CurrentWeatherViewModel()
        viewModel?.delegate = self
        viewModel?.fetchCurrentWeathers()
    }
    
}
