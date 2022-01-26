//
//  CityListTableViewDatSource.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension CityListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CityListTableViewCell = tableView.dequeueReusableCell(withIdentifier: CityListTableViewCell.reuseID, for: indexPath) as? CityListTableViewCell else {
            fatalError("Fail to cast cell")
        }
        
        cell.cityLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin faucibus tortor id nisl rutrum viverra."
        cell.currentTempLabel.text = "123456789.123456789"
        cell.currentHumidityLabel.text = "123456789.123456789"
        
        return cell
    }
    
}
