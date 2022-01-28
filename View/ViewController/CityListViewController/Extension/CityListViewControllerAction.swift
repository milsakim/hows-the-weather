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
    
    /**
     도시의 현재 날씨 정보를 서버로부터 다시 받아온다
     */
    @objc func handleRefreshControl() {
        print("--- \(#function) called ---")
        guard let viewModel = viewModel, !viewModel.isFetchInProgress else {
            tableView.refreshControl?.endRefreshing()
            return
        }
        
        UserDefaults.standard.set(SortingCriterion.name.rawValue, forKey: UserDefaultsKey.sortingCriterion.rawValue)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.isAscending.rawValue)
        cityIDs = []
        tableView.reloadData()
        setupSortingButton()
        viewModel.sortSupportingCityList()
        viewModel.clear()
//        tableView.reloadData()
        viewModel.fetchCurrentWeathers()
        tableView.refreshControl?.endRefreshing()
        print("--- \(#function): end refreshing ---")
    }
        
}
