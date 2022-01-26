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
            if let currentWeather = viewModel.currentWeather[viewModel.supportingCities[indexPath.row].id], let cachedIcon = viewModel.iconCache.object(forKey: currentWeather.weather[0].icon as NSString) {
                let storyboard: UIStoryboard = UIStoryboard(name: "DetailedWeatherViewController", bundle: .main)
                guard let detailedWeatherViewController: DetailedWeatherViewController = storyboard.instantiateViewController(withIdentifier: "DetailedWeatherViewController") as? DetailedWeatherViewController else {
                    print("Fail to cast DetailedWeatherViewController")
                    return
                }
                
                detailedWeatherViewController.city = viewModel.supportingCities[indexPath.row]
                
                detailedWeatherViewController.title = viewModel.supportingCities[indexPath.row].name
                
                navigationController?.pushViewController(detailedWeatherViewController, animated: true)
                
                detailedWeatherViewController.currentWeather = currentWeather
                
                if let cachedIcon = viewModel.iconCache.object(forKey: currentWeather.weather[0].icon as NSString) {
                    detailedWeatherViewController.iconImage = cachedIcon
                }
            }
            else {
                showAlertController()
            }
        }
        
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
    
}

extension CityListViewController {
    
}
