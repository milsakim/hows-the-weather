//
//  DetailedWeatherTableViewDelegate.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension DetailedWeatherViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.row {
        case 2:
            return indexPath
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "ForecastViewController", bundle: .main)
        guard let forecastViewController: ForecastViewController = storyboard.instantiateViewController(withIdentifier: "ForecastViewController") as? ForecastViewController else {
            print("Fail to cast ForecastViewController")
            return
        }
        
        guard let city = city else {
            print("city is nil")
            return
        }
        forecastViewController.cityID = city.id
        forecastViewController.title = "\(city.name) Forecast"
        
        navigationController?.pushViewController(forecastViewController, animated: true)
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
    
}

