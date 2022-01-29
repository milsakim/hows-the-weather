//
//  CurrentWeatherTableViewCell.swift
//  How'sTheWeather
//
//  Created by HyeJee Kim on 2022/01/26.
//

import UIKit

class CurrentWeatherTableViewCell: UITableViewCell {
    
    static let reuseID: String = "CurrentWeatherTableViewCell"

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var maxAndMinTempLabel: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        weatherIconView.backgroundColor = .lightGray
        weatherIconView.layer.cornerRadius = weatherIconView.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        tempLabel.text = ""
        descriptionLabel.text = ""
        maxAndMinTempLabel.text = ""
        weatherIconView.image = nil
    }

}
