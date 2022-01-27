//
//  CityListViewControllerSetup.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension CityListViewController {
    
    func setupNavigation() {
        let sortByCityName: UIAction = UIAction(title: "City Name", state: .off) { action in
            if let viewModel = self.viewModel {
                viewModel.supportingCities.sort {
                    return $0.name > $1.name
                }
                self.tableView.reloadData()
            }
        }
        let sortByTemp: UIAction = UIAction(title: "Temperature", state: .off) { action in
            
        }
        let sortByDistance: UIAction = UIAction(title: "Distance") { action in
            
        }
        let sortingStandardMenu: UIMenu = UIMenu(title: "Sort by", options: [.singleSelection, .displayInline], children: [sortByCityName, sortByTemp, sortByDistance])
        
        let acsendingOrder: UIAction = UIAction(title: "Ascending") { action in
        }
        let descendingOrder: UIAction = UIAction(title: "Descending") { action in
        }
        let orderMenu: UIMenu = UIMenu(title: "In Order", options: [.singleSelection, .displayInline], children: [acsendingOrder, descendingOrder])
        
    
        let sortingMenu: UIMenu = UIMenu(title: "Sort", options: [], children: [sortingStandardMenu, orderMenu])
        
        let sortingButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: nil)
        sortingButton.menu = sortingMenu
        
        let settingButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting-ic"), style: .plain, target: self, action: nil)
        
        navigationItem.setRightBarButton(sortingButton, animated: false)
        navigationItem.setLeftBarButton(settingButton, animated: false)
        
        // back button title 삭제
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setupTableView() {
        // table view의 data source와 delegate 설정
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.refreshControl = UIRefreshControl()
    }

    func setupViewModel() {
        viewModel = CurrentWeatherViewModel()
        viewModel?.delegate = self
        viewModel?.fetchCurrentWeathers()
    }

}
