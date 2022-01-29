//
//  NetworkMonitor.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/28.
//

import Foundation
import Network

final class NetworkMonitor {
    
    static let shared: NetworkMonitor = NetworkMonitor()
    
    private var monitor: NWPathMonitor
    private var queue: DispatchQueue
    
    private init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
}
