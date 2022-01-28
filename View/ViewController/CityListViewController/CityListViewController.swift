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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var tableViewFooter: UIView!
    
    var viewModel: CurrentWeatherViewModel?

    var cityIDs: [String] = []
    
    private let cellHeight: CGFloat = 87.0
    
    var isContentSmaller: Bool {
        cellHeight * CGFloat(tableView.numberOfRows(inSection: 0)) < tableView.frame.height
    }
    
    // MARK: - Deinitialization
    
    deinit {
        viewModel = nil
        cityIDs.removeAll()
        print("--- CityListViewController deinit ---")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isContentSmaller {
            print("--- \(#function): content is smaller ---")
            tableViewFooter.isHidden = false
            loadingIndicator.startAnimating()
            viewModel?.fetchCurrentWeatherData()
        }
    }
    
    // MARK: - Responding to Environment Change
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("--- \(#function) ---")
        
        coordinator.animate(alongsideTransition: nil) { transitionCoordinator in
            if self.isContentSmaller {
                print("--- \(#function): content is smaller ---")
                self.tableViewFooter.isHidden = false
                self.loadingIndicator.startAnimating()
                self.viewModel?.fetchCurrentWeatherData()
            }
        }
    }
    
    // MARK: - Common Initialization
    
    private func commonInit() {
        title = "Today's Weather"
        setupNavigation()
        setupTableView()
        setupViewModel()
    }
    
}
