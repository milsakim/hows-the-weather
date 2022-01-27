//
//  CityListViewControllerSetup.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

enum SortingCriterion: String {
    case name = "name"
    case temperature = "temperature"
    case distance = "distance"
}

extension CityListViewController {
    
    func setupNavigation() {
        setupSortingButton()
        
        let settingButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting-ic"), style: .plain, target: self, action: nil)
        navigationItem.setLeftBarButton(settingButton, animated: false)
        
        // back button title 삭제
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setupSortingButton() {
        let sortByCityName: UIAction = UIAction(title: "City Name", state: .off) { action in
            UserDefaults.standard.set(SortingCriterion.name.rawValue, forKey: UserDefaultsKey.sortingCriterion.rawValue)
            self.viewModel?.sortSupportingCityList()
            self.tableView.reloadData()
        }
        let sortByTemp: UIAction = UIAction(title: "Temperature", state: .off) { action in
            
        }
        let sortByDistance: UIAction = UIAction(title: "Distance") { action in
            
        }
        let sortingStandardMenu: UIMenu = UIMenu(title: "Sort by", options: [.singleSelection, .displayInline], children: [sortByCityName, sortByTemp, sortByDistance])
        
        // 정렬의 오름차순, 내림차순 선택
        var ascendingOrderActionState: UIAction.State = .off
        var decendingOrderActionState: UIAction.State = .off
        
        if UserDefaults.standard.object(forKey: UserDefaultsKey.isAscending.rawValue) as? Bool ?? true {
            ascendingOrderActionState = .on
        }
        else {
            decendingOrderActionState = .on
        }
        
        let acsendingOrder: UIAction = UIAction(title: "Ascending", state: ascendingOrderActionState) { action in
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.isAscending.rawValue)
            self.viewModel?.sortSupportingCityList()
            self.tableView.reloadData()
        }
        let descendingOrder: UIAction = UIAction(title: "Descending", state: decendingOrderActionState) { action in
            UserDefaults.standard.set(false, forKey: UserDefaultsKey.isAscending.rawValue)
            self.viewModel?.sortSupportingCityList()
            self.tableView.reloadData()
        }
        
        let orderMenu: UIMenu = UIMenu(title: "In Order", options: [.singleSelection, .displayInline], children: [acsendingOrder, descendingOrder])
        
    
        let sortingMenu: UIMenu = UIMenu(title: "Sort", options: [], children: [sortingStandardMenu, orderMenu])
        
        let sortingButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: nil)
        sortingButton.menu = sortingMenu
    
        navigationItem.setRightBarButton(sortingButton, animated: false)
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
