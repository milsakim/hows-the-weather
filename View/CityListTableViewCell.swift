//
//  CityListTableViewCell.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

class CityListTableViewCell: UITableViewCell {

    // MARK: - Property
    
    static let reuseID: String = "CityListTableViewCell"
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempAndHumidityLabel: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        weatherIconView.backgroundColor = .gray
        weatherIconView.layer.cornerRadius = weatherIconView.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        weatherIconView.image = nil
    }

}
