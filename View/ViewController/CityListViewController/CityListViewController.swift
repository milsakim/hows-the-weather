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
    
    // table view의 header
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var ascendingButton: UIButton!
    
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
    
    func fetchCompleted(_ indexPaths: [IndexPath]?) {
        if let indexPaths = indexPaths {
            tableView.reloadRows(at: indexPaths, with: .none)
        }
    }
    
    func fetchFailed(error: APIResponseError) {
        print("fetch failed")
    }
    
}
