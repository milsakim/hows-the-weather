//
//  CityListTableViewDelegate.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension CityListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {
            return
        }
        
        if viewModel.isFetchInProgress {
            showAlertController()
        }
        else {
            if let currentWeather = viewModel.currentWeather[String(viewModel.supportingCities[indexPath.row].id)], let cachedIcon = viewModel.iconCache.object(forKey: currentWeather.weather[0].icon as NSString) {
                let storyboard: UIStoryboard = UIStoryboard(name: "DetailedWeatherViewController", bundle: .main)
                guard let detailedWeatherViewController: DetailedWeatherViewController = storyboard.instantiateViewController(withIdentifier: "DetailedWeatherViewController") as? DetailedWeatherViewController else {
                    print("--- Fail to cast DetailedWeatherViewController ---")
                    return
                }
                
                detailedWeatherViewController.city = viewModel.supportingCities[indexPath.row]
                detailedWeatherViewController.title = viewModel.supportingCities[indexPath.row].name
                detailedWeatherViewController.currentWeather = currentWeather
                detailedWeatherViewController.iconImage = cachedIcon
                
                navigationController?.pushViewController(detailedWeatherViewController, animated: true)
            }
            else {
                showAlertController()
            }
        }
        
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
    
}

extension CityListViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("--- \(#function) called: \(tableView.contentSize.height) / \(tableView.frame.size.height)---")
        guard let viewModel = viewModel, viewModel.supportingCities.count != viewModel.currentWeather.count else { return }
        guard !viewModel.isFetchInProgress else { return }
        
        if tableView.contentOffset.y + tableView.frame.size.height >= (tableView.contentSize.height - 50.0) {
//            print("--- \(#function) ---")
            tableViewFooter.isHidden = false
            loadingIndicator.startAnimating()
            viewModel.fetchCurrentWeatherData()
        }
    }
    
}
