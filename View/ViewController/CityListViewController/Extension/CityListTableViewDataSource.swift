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
        return viewModel.supportingCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CityListTableViewCell = tableView.dequeueReusableCell(withIdentifier: CityListTableViewCell.reuseID, for: indexPath) as? CityListTableViewCell else {
            fatalError("Fail to cast cell")
        }
        
        if let viewModel = viewModel {
            let cityID: String = "\(Int(viewModel.supportingCities[indexPath.row].id))"
            
            if let currentWeather = viewModel.currentWeather[cityID] {
                cell.cityLabel.text = currentWeather.name
                cell.currentTempLabel.text = "\(currentWeather.main.temp)"
                cell.currentHumidityLabel.text = "\(currentWeather.main.humidity)"
                
                if let thumbnailURL: URL = URL(string: "https://openweathermap.org/img/wn/" + currentWeather.weather[0].icon + "@2x.png") {
                    
                    URLSession.shared.downloadTask(with: thumbnailURL) { (url, response, Error) in
                        guard let url = url else { return }
                        guard let data = try? Data(contentsOf: url) else { return }
                        
                        DispatchQueue.main.async {
                            if let cellToUpdate = self.tableView.cellForRow(at: indexPath) as? CityListTableViewCell {
                                cellToUpdate.weatherIconView.image = UIImage(data: data)
                            }
                        }
                    }.resume()
                }
            }
            else {
                cell.cityLabel.text = viewModel.supportingCities[indexPath.row].name
                cell.currentTempLabel.text = "Loading..."
                cell.currentHumidityLabel.text = "Loading..."
            }
        }
        
        return cell
    }
    
}
