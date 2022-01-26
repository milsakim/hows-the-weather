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
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            let alertController: UIAlertController = UIAlertController(title: "Loading Weather Data", message: "Please try in few seconds", preferredStyle: .alert)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        }
        else {
            let storyboard: UIStoryboard = UIStoryboard(name: "DetailedWeatherViewController", bundle: .main)
            guard let detailedWeatherViewController: DetailedWeatherViewController = storyboard.instantiateViewController(withIdentifier: "DetailedWeatherViewController") as? DetailedWeatherViewController else {
                print("Fail to cast DetailedWeatherViewController")
                return
            }
            
            detailedWeatherViewController.city = viewModel.supportingCities[indexPath.row]
            detailedWeatherViewController.title = viewModel.supportingCities[indexPath.row].name
            
            navigationController?.pushViewController(detailedWeatherViewController, animated: true)
            
            tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        }
    }
    
}
