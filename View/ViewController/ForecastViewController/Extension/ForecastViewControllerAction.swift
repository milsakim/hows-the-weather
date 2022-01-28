//
//  ForecastViewControllerAction.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/28.
//

import UIKit

extension ForecastViewController {
    
    // MARK: - Presenting Alert Controller
    
    func showFetchingFailureAlert() {
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            print("--- retryAction handler ---")
            self.navigationController?.popViewController(animated: true)
        })
        
        let alertController: UIAlertController = UIAlertController(title: "Fail to Load Forecast Data", message: "Please restart application", preferredStyle: .alert)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
