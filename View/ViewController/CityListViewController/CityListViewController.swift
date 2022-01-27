//
//  CityListViewController.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

class CityListViewController: UIViewController {

    // MARK: - Property
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: CurrentWeatherViewModel?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    private func commonInit() {
        title = "Today's Weather"
        setupNavigation()
        setupTableView()
        setupViewModel()
    }
    
}

extension CityListViewController: ViewModelDelegate {
    
    func fetchCompleted(for indexPaths: [IndexPath]?) {
        if let indexPaths = indexPaths {
            tableView.reloadRows(at: indexPaths, with: .none)
        }
    }
    
    func allSupportedCitiesAreFetched() {
        print("--- \(#function): \(viewModel?.currentWeather.count)")
        
        // 정렬 버튼 활성화 시키기
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func fetchFailed(error: APIResponseError) {
        print("fetch failed")
    }
    
}
