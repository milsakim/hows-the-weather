//
//  CurrentWeatherViewModelDelegate.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/28.
//

import UIKit

extension CityListViewController: CurrentWeatherViewModelDelegate {
    
    func fetchStarted() {
        // 정렬 버튼 비활성화 시키기
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func fetchCompleted(for indexPaths: [IndexPath]?, data: [String]?) {
        print("--- \(#function) called ---")
        tableViewFooter.isHidden = true
        loadingIndicator.stopAnimating()
        
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
        
        if let indexPaths = indexPaths, let newData: [String] = data {
            DispatchQueue.main.async {
                print("--- CityListViewController row is now inserting ---")
                self.tableView.beginUpdates()
                self.cityIDs += newData
                self.tableView.insertRows(at: indexPaths, with: .none)
                self.tableView.endUpdates()
                
                if self.isContentSmaller {
                    print("--- \(#function): content is smaller ---")
                    self.tableViewFooter.isHidden = false
                    self.loadingIndicator.startAnimating()
                    self.viewModel?.fetchCurrentWeatherData()
                }
            }
        }
    }
    
    func allSupportedCitiesAreFetched() {
        print("--- \(#function) called ---")
        
        // 정렬 버튼 활성화 시키기
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func fetchFailed(error: APIResponseError) {
        print("--- fetch failed: \(error.reason) ---")
        // 데이터 fetch 실패 처리
        if let viewModel = viewModel {
            viewModel.clear()
            cityIDs = []
            tableViewFooter.isHidden = true
            loadingIndicator.stopAnimating()
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
            tableView.reloadData()
            showFetchingFailureAlertController()
        }
    }
    
}
