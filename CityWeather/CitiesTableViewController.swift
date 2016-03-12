//
//  CitiesTableViewController.swift
//  CityWeather
//
//  Created by Svit Zebec on 10/03/16.
//  Copyright © 2016 Svit Zebec. All rights reserved.
//

import UIKit

let userDefaultsCitiesKey = "storedCities"

class CitiesTableViewController: UITableViewController, NSURLSessionDataDelegate {

	var cities = [City]()
	var currentlySelectedCity: City? = nil

	override func viewDidLoad() {
		super.viewDidLoad()

		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: Selector("pullToRefresh"), forControlEvents: .ValueChanged)
		loadCitiesFromUserDefaults()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("CityCell", forIndexPath: indexPath) as! CityCell

		let cityName = cities[indexPath.row].name
		cell.cityNameLabel.text = cityName
		cell.cityTemperatureLabel.text = ""
		fetchWeatherDataForCell(cell, cityName: cityName)

		return cell
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cities.count
	}

	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			deleteCity(indexPath)
		}
	}

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	@IBAction func cancelAddingCity(segue: UIStoryboardSegue) {}

	@IBAction func doneAddingCity(segue: UIStoryboardSegue) {
		let addCityViewController = segue.sourceViewController as! AddCityViewController
		addCity(addCityViewController.cityName)
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		currentlySelectedCity = cities[indexPath.row]
		performSegueWithIdentifier("showCityDetails", sender: self)
	}

	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if identifier == "showCityDetails" {
			return currentlySelectedCity != nil
		}
		return true
	}

	private func fetchWeatherDataForCell(cell: CityCell, cityName: String) {
		let urlString = "\(apiUrl)?q=\(cityName)&appid=\(apiKey)&units=metric"
		let url = NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
		let session = NSURLSession.sharedSession()
		let request = NSMutableURLRequest(URL: url!)

		let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> () in

			// the requests are sent consecutivelly very fast so it often happens that the server
			// returns 429 - to many request, that is why the fetch is repeated
			if ((response as! NSHTTPURLResponse).statusCode == 429) {
				dispatch_async(dispatch_get_main_queue()) {
					self.fetchWeatherDataForCell(cell, cityName: cell.cityNameLabel.text!)
				}
				return
			}
			if error != nil {
				dispatch_async(dispatch_get_main_queue()) {
					cell.cityTemperatureLabel.text = "/"
				}

				return
			}

			do {
				let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
				let temperature = (jsonData["main"] as! NSDictionary)["temp"] as! Int

				self.setCityTemperatureLabel(temperature, cell: cell)

			} catch {
				dispatch_async(dispatch_get_main_queue()) {
					cell.cityTemperatureLabel.text = "/"
				}
			}
		})
		
		dataTask.resume()

	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showCityDetails" {
			if let cityDetailsViewController: CityDetailsViewController = segue.destinationViewController as? CityDetailsViewController {
				cityDetailsViewController.cityName = currentlySelectedCity!.name
			}
		}
	}

	private func setCityTemperatureLabel(temperature: Int, cell: CityCell) {
		dispatch_async(dispatch_get_main_queue()) {
			UIView.transitionWithView(cell.cityTemperatureLabel,
				duration: 0.5,
				options: .TransitionCrossDissolve,
				animations: {() in
					cell.cityTemperatureLabel.text = "\(temperature)\u{00B0}"
				}, completion: nil)
		}
	}

	private func deleteCity(indexPath: NSIndexPath) {
		cities.removeAtIndex(indexPath.row)
		tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

		storeLocalCitiesToUserDefaults()
	}

	private func addCity(cityName: String) {
		let newCity = City(name: cityName)
		cities.append(newCity)
		let insertedIndex = cities.count - 1

		tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: insertedIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)

		storeLocalCitiesToUserDefaults()
	}

	func pullToRefresh() {
		tableView.reloadData()
		refreshControl?.endRefreshing()
	}

	private func loadCitiesFromUserDefaults() {
		let userDefaults = NSUserDefaults.standardUserDefaults()
		let persistedCitiesData = userDefaults.objectForKey(userDefaultsCitiesKey) as? NSData

		if let persistedCitiesDataUnwrapped = persistedCitiesData {
			cities = NSKeyedUnarchiver.unarchiveObjectWithData(persistedCitiesDataUnwrapped) as! [City]
		}
	}

	private func storeLocalCitiesToUserDefaults() {
		let userDefaults = NSUserDefaults.standardUserDefaults()
		let archivedCities = NSKeyedArchiver.archivedDataWithRootObject(cities as NSArray)

		userDefaults.setObject(archivedCities, forKey: userDefaultsCitiesKey)
		userDefaults.synchronize()
	}

}
