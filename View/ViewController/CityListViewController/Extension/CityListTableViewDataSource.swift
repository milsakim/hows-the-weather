//
//  CityListTableViewDatSource.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension CityListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {
            return 0
        }
        
        return viewModel.currentWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CityListTableViewCell = tableView.dequeueReusableCell(withIdentifier: CityListTableViewCell.reuseID, for: indexPath) as? CityListTableViewCell else {
            fatalError("Fail to cast cell")
        }

        if let viewModel = viewModel {
            // 해당 도시의 날씨 정보가 fetch 되어있는 경우
            if let currentWeather = viewModel.currentWeather[String(viewModel.supportingCities[indexPath.row].id)] {
                cell.cityLabel.text = currentWeather.name
                cell.tempAndHumidityLabel.text = "\(currentWeather.main.temp) ℃ / \(currentWeather.main.humidity) %"
                
                if let icon = viewModel.iconCache.object(forKey: currentWeather.weather[0].icon as NSString) {
                    cell.weatherIconView.image = icon
                }
                else {
                    if let thumbnailURL: URL = URL(string: "https://openweathermap.org/img/wn/" + currentWeather.weather[0].icon + "@2x.png") {
                        
                        URLSession.shared.downloadTask(with: thumbnailURL) { (url, response, Error) in
                            guard let url = url else { return }
                            guard let data = try? Data(contentsOf: url) else { return }
                            guard let image = UIImage(data: data) else {
                                return
                            }
                            viewModel.iconCache.setObject(image, forKey: currentWeather.weather[0].icon as NSString)
                            DispatchQueue.main.async {
                                if let cellToUpdate = self.tableView.cellForRow(at: indexPath) as? CityListTableViewCell {
                                    cellToUpdate.weatherIconView.image = image
                                }
                            }
                        }.resume()
                    }
                }
            }
            else {
                cell.cityLabel.text = viewModel.supportingCities[indexPath.row].name
                cell.tempAndHumidityLabel.text = "-- ℃ / -- %"
            }
        }
        else {
            cell.cityLabel.text = "---"
            cell.tempAndHumidityLabel.text = "-- ℃ / -- %"
        }
        
        return cell
    }
    
}
