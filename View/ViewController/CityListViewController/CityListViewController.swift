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
    @IBOutlet var tableViewFooter: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
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
    
    func fetchStarted() {
        // 정렬 버튼 비활성화 시키기
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func fetchCompleted(for indexPaths: [IndexPath]?) {
        print("--- \(#function) ---")
        tableViewFooter.isHidden = true
        loadingIndicator.stopAnimating()
        
        if let indexPaths = indexPaths {
            tableView.insertRows(at: indexPaths, with: .none)
        }
        
        if tableView.contentSize.height < tableView.frame.size.height {
            print("--- content is smaller ---")
            tableViewFooter.isHidden = false
            loadingIndicator.startAnimating()
            viewModel?.fetchCurrentWeathers()
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
