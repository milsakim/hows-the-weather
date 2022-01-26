//
//  DetailedWeatherTableViewDataSource.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension DetailedWeatherViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell: CurrentWeatherTableViewCell = tableView.dequeueReusableCell(withIdentifier: CurrentWeatherTableViewCell.reuseID, for: indexPath) as? CurrentWeatherTableViewCell else {
                fatalError("Fail to cast cell")
            }
            
            if let currentWeather = currentWeather {
                cell.tempLabel.text = "\(currentWeather.main.temp)"
                cell.descriptionLabel.text = currentWeather.weather[0].description
                cell.feelsLikeLabel.text = "Feels like \(currentWeather.main.feels_like)"
                cell.maxAndMinTempLabel.text = "Max \(currentWeather.main.temp_max) / Min \(currentWeather.main.temp_min)"
                cell.weatherIconView.image = iconImage
            }
            
            return cell
        case 1:
            guard let cell: DetailedWeatherInfoCell = tableView.dequeueReusableCell(withIdentifier: DetailedWeatherInfoCell.reuseID, for: indexPath) as? DetailedWeatherInfoCell else {
                fatalError("Fail to cast cell")
            }
            
            if let currentWeather = currentWeather {
                cell.humidityInfoLabel.text = "\(currentWeather.main.humidity)"
                cell.pressureInfoLabel.text = "\(currentWeather.main.pressure)"
                cell.windInfoLabel.text = "\(currentWeather.wind.speed)"
            }
            
            return cell
        default:
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = "Forecast"
            cell.accessoryType = .disclosureIndicator
            cell.contentConfiguration = config
            return cell
        }
    }
    
    
}
