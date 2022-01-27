//
//  CityListViewControllerSetup.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension CityListViewController {
    
    func setupNavigation() {
        let sortByCityName: UIAction = UIAction(title: "City Name") { action in
            if let viewModel = self.viewModel {
                viewModel.supportingCities.sort {
                    return $0.name > $1.name
                }
                self.tableView.reloadData()
            }
        }
        let sortByTemp: UIAction = UIAction(title: "Temperature") { action in
            
        }
        let sortByDistance: UIAction = UIAction(title: "Distance") { action in
            
        }
        let sortingMenu: UIMenu = UIMenu(title: "Sort by", children: [sortByCityName, sortByTemp, sortByDistance])
        let sortingButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: nil)
        sortingButton.menu = sortingMenu
        
        let settingButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting-ic"), style: .plain, target: self, action: nil)
        
        navigationItem.setRightBarButton(sortingButton, animated: false)
        navigationItem.setLeftBarButton(settingButton, animated: false)
    }
    
    func setupTableView() {
        // table view의 data source와 delegate 설정
        tableView.dataSource = self
        tableView.delegate = self
        
        // table view의 header 설정
//        tableView.tableHeaderView = headerView
//        setupTableHeaderView()
        
        tableView.refreshControl = UIRefreshControl()
    }

    func setupViewModel() {
        viewModel = CurrentWeatherViewModel()
        viewModel?.delegate = self
        viewModel?.fetchCurrentWeathers()
    }

}
