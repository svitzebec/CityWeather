//
//  City.swift
//  CityWeather
//
//  Created by Svit Zebec on 12/03/16.
//  Copyright © 2016 Svit Zebec. All rights reserved.
//

import Foundation

class City: NSObject, NSCoding {

	var name: String = ""
	var temperature: Double? = nil

	init(name: String) {
		self.name = name
	}

	init(name: String, temperature: Double) {
		self.name = name
		self.temperature = temperature
	}

	required init?(coder aDecoder: NSCoder) {
		name = aDecoder.decodeObjectForKey("name") as! String
		temperature = aDecoder.decodeObjectForKey("temperature") as? Double
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(name, forKey: "name")
		aCoder.encodeObject(temperature, forKey: "temperature")
	}
}
