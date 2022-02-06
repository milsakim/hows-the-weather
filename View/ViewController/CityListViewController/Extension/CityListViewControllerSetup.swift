//
//  CityListViewControllerSetup.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension CityListViewController {
    
    // MARK: - Navigation Setup
    
    func setUpNavigation() {
        guard navigationController != nil else {
            return
        }
        
        setUpSortingNavItem()
        setUpPreferencesNavItem()
        
        // back button title 삭제
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setUpSortingNavItem() {
        guard self.navigationController != nil else {
            return
        }
        
        var sortByCityNameActionState: UIAction.State = .off
        var sortByTempActionState: UIAction.State = .off
        var sortByDistanceActionState: UIAction.State = .off
        
        let sortingCriterionString: String = UserDefaults.standard.object(forKey: UserDefaultsKey.sortingCriterion) as? String ?? SortingCriterion.name.rawValue
        switch SortingCriterion(rawValue: sortingCriterionString) {
        case .name:
            sortByCityNameActionState = .on
        case .temperature:
            sortByTempActionState = .on
        case .distance:
            sortByDistanceActionState = .on
        default:
            sortByCityNameActionState = .on
        }
        
        let sortByCityName: UIAction = UIAction(title: LocalizationKey.cityName.localized, state: sortByCityNameActionState) { action in
            UserDefaults.standard.set(SortingCriterion.name.rawValue, forKey: UserDefaultsKey.sortingCriterion)
            self.viewModel?.sortSupportingCityList()
            self.tableView.reloadData()
        }
        
        let sortByTemp: UIAction = UIAction(title: LocalizationKey.temperature.localized, state: sortByTempActionState) { action in
            UserDefaults.standard.set(SortingCriterion.temperature.rawValue, forKey: UserDefaultsKey.sortingCriterion)
            self.viewModel?.sortSupportingCityList()
            self.tableView.reloadData()
        }
        
        let sortByDistance: UIAction = UIAction(title: LocalizationKey.distance.localized, state: sortByDistanceActionState) { action in
            UserDefaults.standard.set(SortingCriterion.distance.rawValue, forKey: UserDefaultsKey.sortingCriterion)
            self.viewModel?.sortSupportingCityList()
            self.tableView.reloadData()
        }
        
        let sortingStandardMenu: UIMenu = UIMenu(title: "Sort by", options: [.singleSelection, .displayInline], children: [sortByCityName, sortByTemp, sortByDistance])
        
        // 정렬의 오름차순, 내림차순 선택
        var ascendingOrderActionState: UIAction.State = .off
        var decendingOrderActionState: UIAction.State = .off
        
        if UserDefaults.standard.object(forKey: UserDefaultsKey.isAscending) as? Bool ?? true {
            ascendingOrderActionState = .on
        }
        else {
            decendingOrderActionState = .on
        }
        
        let acsendingOrder: UIAction = UIAction(title: LocalizationKey.ascending.localized, state: ascendingOrderActionState) { action in
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.isAscending)
            self.viewModel?.sortSupportingCityList()
            self.tableView.reloadData()
        }
        
        let descendingOrder: UIAction = UIAction(title: LocalizationKey.descending.localized, state: decendingOrderActionState) { action in
            UserDefaults.standard.set(false, forKey: UserDefaultsKey.isAscending)
            self.viewModel?.sortSupportingCityList()
            self.tableView.reloadData()
        }
        
        let orderMenu: UIMenu = UIMenu(title: "In Order", options: [.singleSelection, .displayInline], children: [acsendingOrder, descendingOrder])
        
        
        let sortingMenu: UIMenu = UIMenu(title: LocalizationKey.sort.localized, options: [], children: [sortingStandardMenu, orderMenu])
        
        let sortingButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: nil)
        sortingButton.menu = sortingMenu
        
        navigationItem.setRightBarButton(sortingButton, animated: false)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func setUpPreferencesNavItem() {
        guard self.navigationController != nil else {
            return
        }
        
        let settingButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting-ic"), style: .plain, target: self, action: nil)
        navigationItem.setLeftBarButton(settingButton, animated: false)
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        var celsiusActionState: UIAction.State = .off
        var fahrenheitActionState: UIAction.State = .off
        
        let unitString: String = UserDefaults.standard.object(forKey: UserDefaultsKey.unit) as? String ?? MeasurementUnit.celsius.rawValue
        switch MeasurementUnit(rawValue: unitString) {
        case .celsius:
            celsiusActionState = .on
        case .fahrenheit:
            fahrenheitActionState = .on
        default:
            celsiusActionState = .on
        }
        
        let celsius: UIAction = UIAction(title: LocalizationKey.celsicus.localized, state: celsiusActionState) { action in
            UserDefaults.standard.set(MeasurementUnit.celsius.rawValue, forKey: UserDefaultsKey.unit)
            
            // 데이터 다시 fetch
            self.clearData()
            self.viewModel?.fetchCurrentWeatherData()
        }
        
        let fahrenheit: UIAction = UIAction(title: LocalizationKey.fahrenheit.localized, state: fahrenheitActionState) { action in
            UserDefaults.standard.set(MeasurementUnit.fahrenheit.rawValue, forKey: UserDefaultsKey.unit)
            
            // 데이터 다시 fetch
            self.clearData()
            self.viewModel?.fetchCurrentWeatherData()
        }
        
        let unitsMenu: UIMenu = UIMenu(title: "Unit", options: [.singleSelection, .displayInline], children: [celsius, fahrenheit])
        

        let preferencesMenu: UIMenu = UIMenu(title: LocalizationKey.prefrences.localized, options: [], children: [unitsMenu])
        
        settingButton.menu = preferencesMenu
    }
    
    // MARK: - Table View Setup
    
    func setupTableView() {
        guard tableView != nil else {
            return
        }
        
        // table view의 data source와 delegate 설정
        tableView.dataSource = self
        tableView.delegate = self
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        
        tableView.tableFooterView = tableViewFooter
        tableViewFooter.isHidden = true
    }
    
    // MARK: - View Model Setup
    
    func setupViewModel() {
        viewModel = CurrentWeatherViewModel()
        
        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.delegate = self
        viewModel.readJSONData()
        
        guard !viewModel.isReadingJSONFailed else {
            showFetchingFailureAlert()
            return
        }
        
        viewModel.fetchCurrentWeatherData()
    }
    
}
