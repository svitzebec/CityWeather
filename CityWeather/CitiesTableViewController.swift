//
//  CitiesTableViewController.swift
//  CityWeather
//
//  Created by Svit Zebec on 10/03/16.
//  Copyright © 2016 Svit Zebec. All rights reserved.
//

import UIKit

class CitiesTableViewController: UITableViewController {

	var cities = [String]()

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("CityCell", forIndexPath: indexPath)

		cell.textLabel?.text = cities[indexPath.row]

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

	private func addCity(cityName: String) {
		cities.append(cityName)
		let insertedIndex = cities.count - 1

		tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: insertedIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
	}

}
