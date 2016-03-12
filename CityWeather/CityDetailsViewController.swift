//
//  CityDetailsViewController.swift
//  CityWeather
//
//  Created by Svit Zebec on 11/03/16.
//  Copyright © 2016 Svit Zebec. All rights reserved.
//

import UIKit

let apiKey = "1e9cb973e0633953339820e19d5a6675"
let apiUrl = "http://api.openweathermap.org/data/2.5/weather"

class CityDetailsViewController: UIViewController {

	var cityName = ""
	@IBOutlet var cityNameLabel: UILabel!
	@IBOutlet var fetchedCityNameLabel: UILabel!
	@IBOutlet var weatherDescriptionLabel: UILabel!
	@IBOutlet var temperatureLabel: UILabel!
	@IBOutlet var humidityLabel: UILabel!
	@IBOutlet var displayView: UIView!
	@IBOutlet var errorLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		errorLabel.hidden = true
		cityNameLabel.text = cityName

		fetchWeatherData()
	}

	private func fetchWeatherData() {
		let urlString = "\(apiUrl)?q=\(cityName)&appid=\(apiKey)&units=metric"
		let url = NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
		let session = NSURLSession.sharedSession()
		let request = NSMutableURLRequest(URL: url!)

		let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> () in
			if error != nil {
				self.showErrorMessage()

				return
			}

			do {
				let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary

				let temperature = (jsonData["main"] as! NSDictionary)["temp"] as! Int
				let humidity = (jsonData["main"] as! NSDictionary)["humidity"] as! Int
				let description = ((jsonData["weather"] as! NSArray)[0] as! NSDictionary)["description"] as! String
				let name = jsonData["name"] as! String

				self.setCityDetailsInfo(temperature, humidity: humidity, description: description, name: name)

			} catch {
				self.showErrorMessage()
			}
		})

		dataTask.resume()
	}

	private func setCityDetailsInfo(temperature: Int, humidity: Int, description: String, name: String) {
		dispatch_async(dispatch_get_main_queue()) {
			UIView.transitionWithView(self.displayView,
				duration: 0.5,
				options: .TransitionCrossDissolve,
				animations: {() in
					self.temperatureLabel.text = "\(temperature)\u{00B0}"
					self.humidityLabel.text = "Humidity: \(humidity)%"
					self.weatherDescriptionLabel.text = description
					self.fetchedCityNameLabel.text = name
				}, completion: nil)
		}
	}

	private func showErrorMessage() {
		dispatch_async(dispatch_get_main_queue()) {
			self.displayView.hidden = true
			self.errorLabel.hidden = false
		}
	}

}
