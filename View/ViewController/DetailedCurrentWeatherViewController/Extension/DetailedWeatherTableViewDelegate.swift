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
    
}

