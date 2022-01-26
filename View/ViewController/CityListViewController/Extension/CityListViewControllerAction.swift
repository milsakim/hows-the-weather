//
//  CityListViewControllerAction.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

extension CityListViewController {
    
    func showAlertController() {
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        let alertController: UIAlertController = UIAlertController(title: "Loading Weather Data", message: "Please try in few seconds", preferredStyle: .alert)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
