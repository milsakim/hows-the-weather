//
//  CityListTableViewDelegate.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension CityListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        
        guard let viewModel = viewModel else {
            return
        }
        
        if viewModel.isFetchInProgress {
            showDataFetchingInProgressAlert()
        }
        else {
            pushViewController(indexPath: indexPath)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("--- \(#function) called: \(tableView.contentSize.height) / \(tableView.frame.size.height)---")
        guard let viewModel = viewModel else {
            return
        }
        
        guard !viewModel.isFetchInProgress, cityList.count != viewModel.availableCityListCount else {
            return
        }
        
        if tableView.contentOffset.y + tableView.frame.size.height >= (tableView.contentSize.height - 50.0) {
//            print("--- \(#function) ---")
            tableViewFooter.isHidden = false
            loadingIndicator.startAnimating()
            viewModel.fetchCurrentWeatherData()
        }
    }
    
}
