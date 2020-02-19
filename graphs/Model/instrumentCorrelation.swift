//
//  instrumentCorrelation.swift
//  graphs
//
//  Created by Danila Ferents on 17.02.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import Foundation

///struct for instrument correlation
struct instrumentCorrelation {

	///name of the first currency
	var firstCurrency: String
	///name of the second currency
	var secondCurrency: String
	///correlation between first and second currencies
	var correlation: Double
	///time period for correlation
	var timePeriod: String

}

extension instrumentCorrelation{
	var instrument: String{
		return "\(firstCurrency)-\(secondCurrency)"
	}
}
