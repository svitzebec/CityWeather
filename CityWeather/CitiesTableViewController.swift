//
//  CitiesTableViewController.swift
//  CityWeather
//
//  Created by Svit Zebec on 10/03/16.
//  Copyright © 2016 Svit Zebec. All rights reserved.
//

import UIKit

let userDefaultsCitiesKey = "storedCities"

class CitiesTableViewController: UITableViewController {

	var cities = [City]()
	var currentlySelectedCity: City? = nil

	override func viewDidLoad() {
		super.viewDidLoad()

		loadCitiesFromUserDefaults()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("CityCell", forIndexPath: indexPath)

		cell.textLabel?.text = cities[indexPath.row].name

		return cell
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cities.count
	}

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	@IBAction func cancelAddingCity(segue: UIStoryboardSegue) {

	}

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

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showCityDetails" {
			if let cityDetailsViewController: CityDetailsViewController = segue.destinationViewController as? CityDetailsViewController {
				cityDetailsViewController.cityName = currentlySelectedCity!.name
			}
		}
	}

	private func addCity(cityName: String) {
		let newCity = City(name: cityName)
		cities.append(newCity)
		let insertedIndex = cities.count - 1

		tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: insertedIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)

		storeLocalCitiesToUserDefaults()
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
