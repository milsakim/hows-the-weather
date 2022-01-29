//
//  CityListViewControllerAction.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension CityListViewController {
    
    // MARK: - Navigating to DetailedWeatherViewController
    
    func pushViewController(indexPath: IndexPath) {
        guard let viewModel = viewModel else {
            return
        }
        
        let id: String = String(cityList[indexPath.row].id)
        if let currentWeather = viewModel.currentWeather[id], let cachedIcon = viewModel.iconCache.object(forKey: currentWeather.weather[0].icon as NSString) {
            let storyboard: UIStoryboard = UIStoryboard(name: "DetailedWeatherViewController", bundle: .main)
            guard let detailedWeatherViewController: DetailedWeatherViewController = storyboard.instantiateViewController(withIdentifier: "DetailedWeatherViewController") as? DetailedWeatherViewController else {
                print("--- Fail to cast DetailedWeatherViewController ---")
                return
            }
            
            switch PreferredLocalization(rawValue: Bundle.main.preferredLocalizations[0]) {
            case .english:
                detailedWeatherViewController.title = cityList[indexPath.row].name
            default:
                detailedWeatherViewController.title = cityList[indexPath.row].kr_name
            }
            
            detailedWeatherViewController.city = cityList[indexPath.row]
            detailedWeatherViewController.currentWeather = currentWeather
            detailedWeatherViewController.iconImage = cachedIcon
            
            navigationController?.pushViewController(detailedWeatherViewController, animated: true)
        }
        else {
            showDataLoadingAlert()
        }
    }
    
    // MARK: - Presenting Alert Controller
    
    func showDataLoadingAlert() {
        let alertController: UIAlertController = UIAlertController(title: "Loading Weather Data", message: "Please try in few seconds", preferredStyle: .alert)
        
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showFetchingFailureAlert() {
        let alertController: UIAlertController = UIAlertController(title: "Fail to Load Weather Data", message: "Please restart application", preferredStyle: .alert)

        let retryAction: UIAlertAction = UIAlertAction(title: "Retry", style: .default, handler: { action in
            print("--- retryAction handler ---")
            
            if self.viewModel == nil {
                return
            }
            
            self.tableViewFooter.isHidden = false
            self.loadingIndicator.startAnimating()
            self.viewModel?.isFetchInProgress = false
            self.viewModel?.fetchCurrentWeatherData()
        })
        
        alertController.addAction(retryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    

    // MARK: - Table View Refresh Control Action
    
    @objc func handleRefreshControl() {
        print("--- \(#function) called ---")
        
        guard let viewModel = viewModel, !viewModel.isFetchInProgress else {
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
            
            return
        }
        
        clearData()
        
        viewModel.fetchCurrentWeatherData()
        
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Clear Data
    
    func clearData() {
        guard let viewModel = viewModel else {
            return
        }
        
        UserDefaults.standard.set(SortingCriterion.name.rawValue, forKey: UserDefaultsKey.sortingCriterion)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.isAscending)
        
        cityList.removeAll()
        tableView.reloadData()
        
        setUpSortingNavItem()
        
        viewModel.clear()
    }
    
    
        
}
