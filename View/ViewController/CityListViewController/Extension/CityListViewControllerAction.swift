//
//  CityListViewControllerAction.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension CityListViewController {
    
    func showAlertController() {
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        let alertController: UIAlertController = UIAlertController(title: "Loading Weather Data", message: "Please try in few seconds", preferredStyle: .alert)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func reloadAllData() {
        guard let viewModel = viewModel, !viewModel.isFetchInProgress else {
            tableView.refreshControl?.endRefreshing()
            return
        }
        
        UserDefaults.standard.set(SortingCriterion.name.rawValue, forKey: UserDefaultsKey.sortingCriterion.rawValue)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.isAscending.rawValue)
        cityIDs = []
        setupSortingButton()
        viewModel.sortSupportingCityList()
        viewModel.clear()
        tableView.reloadData()
        viewModel.fetchCurrentWeathers()
        tableView.refreshControl?.endRefreshing()
    }
    
}
