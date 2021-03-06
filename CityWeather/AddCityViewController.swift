//
//  AddCityViewController.swift
//  CityWeather
//
//  Created by Svit Zebec on 10/03/16.
//  Copyright © 2016 Svit Zebec. All rights reserved.
//

import UIKit

let doneAddingCitySegueIdentifier = "doneAddingCity"

class AddCityViewController: UIViewController {

	var cityName: String = ""

	@IBOutlet var cityNameTextField: UITextField!

	// MARK: - View controller lifecycle functions

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewDidAppear(animated: Bool) {
		cityNameTextField.becomeFirstResponder()
	}

	// MARK: - Segue functions

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == doneAddingCitySegueIdentifier {
			cityName = cityNameTextField.text!
		}
	}

	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if identifier == doneAddingCitySegueIdentifier {
			// The done city action could be performed only if the city name 
			// has been entered
			return !cityNameTextField.text!.isEmpty
		} else {
			return true
		}
	}

	
}
