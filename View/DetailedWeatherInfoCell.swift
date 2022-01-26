//
//  DetailedWeatherInfoCell.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

class DetailedWeatherInfoCell: UITableViewCell {
    
    static let reuseID: String = "DetailedWeatherInfoCell"

    @IBOutlet weak var humidityInfoLabel: UILabel!
    @IBOutlet weak var pressureInfoLabel: UILabel!
    @IBOutlet weak var windInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
