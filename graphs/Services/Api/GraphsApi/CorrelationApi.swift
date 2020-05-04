//
//  CorrelationApi.swift
//  graphs
//
//  Created by Danila Ferents on 23.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import Foundation

class CorrelationApi {
	
	static let sharedManager = CorrelationApi()

	private init() {
	}

	/**
	recallculationg values for two quote arrays
	- Author: Danila Ferents
	- Parameters:
	- firstquotes: quotes of first instrument
	- transactions: quotes of second instrument
	- Returns:
	*/
	func correlationQuotesNormed(firstquotes: [QuotePeriod], secondquotes: [QuotePeriod]) -> ([(Double, Double)], [(Double, Double)]) {
		let maxfirstinstrument = firstquotes.max { (quote1, quote2) -> Bool in
			return quote1.exchangeRate < quote2.exchangeRate
		}?.exchangeRate
		let minfirstinstrument = firstquotes.min { (quote1, quote2) -> Bool in
			return quote1.exchangeRate < quote2.exchangeRate
		}?.exchangeRate
		let maxsecondinstrument = secondquotes.max { (quote1, quote2) -> Bool in
			return quote1.exchangeRate < quote2.exchangeRate
		}?.exchangeRate
		let minsecondinstrument = secondquotes.min { (quote1, quote2) -> Bool in
			return quote1.exchangeRate < quote2.exchangeRate
		}?.exchangeRate

		let newquotesfirstinstrument = firstquotes.map { (quote) -> (Double, Double) in
			return (Double(quote.timestamp), (quote.exchangeRate - (minfirstinstrument ?? 0)) / ((maxfirstinstrument ?? 1) - (minfirstinstrument ?? 0)))
		}

		let secondquotesfirstinstrument = secondquotes.map { (quote) -> (Double, Double) in
			return (Double(quote.timestamp), (quote.exchangeRate - (minsecondinstrument ?? 0)) / ((maxsecondinstrument ?? 1) - (minsecondinstrument ?? 0)))
		}
		return (newquotesfirstinstrument, secondquotesfirstinstrument)
	}
	/**
	callculationg correlation for two quote arrays
	cov(x,y)/((Standard Deviation1)*(Standard Deviation2)
	- Author: Danila Ferents
	- Parameters:
	- firstquotes: quotes of first instrument
	- transactions: quotes of second instrument
	- Returns: Double
	*/
	func correlationQuotes(firstquotes: [QuotePeriod], secondquotes: [QuotePeriod]) -> Double {
		var firstaverage = firstquotes.reduce(0) { (result, quote) -> Double in
			return result + quote.exchangeRate
		}

		var secondaverage = secondquotes.reduce(0) { (result, quote) -> Double in
			return result + quote.exchangeRate
		}

		var cov = 0.0
		var sizequotes = 0
		if firstquotes.count < secondquotes.count {
			sizequotes = firstquotes.count
		} else {
			sizequotes = secondquotes.count
		}

		firstaverage /= Double(sizequotes)
		secondaverage /= Double(sizequotes)

		for i in 0..<sizequotes {
			cov += (firstquotes[i].exchangeRate - firstaverage) * (secondquotes[i].exchangeRate - secondaverage)
		}

		var sumfirst = 0.0
		for i in 0..<sizequotes {
			sumfirst += pow(firstquotes[i].exchangeRate - firstaverage, 2)
		}

		var sumsecond = 0.0
		for i in 0..<sizequotes {
			sumsecond += pow(secondquotes[i].exchangeRate - secondaverage, 2)
		}

		let denominator = pow(sumfirst * sumsecond, 0.5)

		let correl = cov / denominator
		if correl.isNaN {
			return 0.0
		} else {
			return correl
		}
	}
}
