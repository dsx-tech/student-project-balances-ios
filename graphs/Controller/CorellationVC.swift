//
//  CorellationVC.swift
//  graphs
//
//  Created by Danila Ferents on 16.02.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit

class CorrelationVC: UIViewController {
	
	//Variables
	var instrumentCorrelations: [instrumentCorrelation] = []
	@IBOutlet weak var quotestable: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		quotestable.delegate = self
		//здесь была ошибка про инициализацию через register спросить потом 
		quotestable.register(UINib(nibName: "quoteCell", bundle: nil), forCellReuseIdentifier: Identifiers.quoteCell)
		quotestable.dataSource = self
		let formatter = DateFormatter()
		
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		
		guard let start = formatter.date(from: "2019-01-01T00:00:01") else {return}
		
		callculatecorrelation(firstinstrument: "eur-usd", secondinstrument: "btc-usd", startDate: start, duration: .month)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? AddIInstrumentVC {
			vc.vc = self
		}
	}
	
	/**
	callculationg correlation from start date for duration between two instruments
	- Author: Danila Ferents
	- Parameters:
	- firstinstrument: first instrument to callculate
	- secondinstrument: second instrument to callculate
	- startDate: Start date of interval
	- duration: quotesDuration enum
	- Returns: corellation value
	*/
	func callculatecorrelation(firstinstrument: String, secondinstrument: String, startDate: Date, duration: durationQuotes) {
		
		//number of months to count corellation, which we take from duration parameter
		var dateComponents =  DateComponents()
		switch duration {
			
		case .month:
			dateComponents.month = 1
		case .threemonths:
			dateComponents.month = 3
		case .sixmonths:
			dateComponents.month = 6
		case .year:
			dateComponents.month = 12
		@unknown default:
			dateComponents.month = 0
		}
		
		guard let enddate = Calendar.current.date(byAdding: dateComponents, to: startDate) else {
			print("Error in converting end date.")
			return
		}
		//get quotes for first instrument
		let quotesApi = TradeApi()
		quotesApi.getQuotesinPeriod(url: Urls.quotesurl, instrument: firstinstrument, startTime: startDate, endTime: enddate) { (firstinstrumentquotes) in
			quotesApi.getQuotesinPeriod(url: Urls.quotesurl, instrument: secondinstrument, startTime: startDate, endTime: enddate) { (secondinstrumentquotes) in
				guard let firstQuotes = firstinstrumentquotes, let secondQuotes = secondinstrumentquotes else {
					print("Error in getting quotes for  instrument")
					return
				}
				//				let correlation = self.correlationQuotes(firstquotes: firstQuotes, secondquotes: secondQuotes)
				
				let correl = instrumentCorrelation(firstCurrency: String(secondinstrument.split(separator: "-").first ?? ""), secondCurrency: String(secondinstrument.split(separator: "-")[1]), correlation: self.correlationQuotes(firstquotes: firstQuotes, secondquotes: secondQuotes), timePeriod: "months: \(dateComponents.month!)")
				self.instrumentCorrelations.append(correl)
				print(self.instrumentCorrelations)
				self.quotestable.reloadData()
			}
		}
		
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
	func correlationQuotes(firstquotes: [Quote], secondquotes: [Quote]) -> Double {
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
		
		firstaverage = firstaverage / Double(sizequotes)
		secondaverage = secondaverage / Double(sizequotes)
		
		for i in 0..<sizequotes {
			cov = cov + (firstquotes[i].exchangeRate - firstaverage) * (secondquotes[i].exchangeRate - secondaverage)
		}
		
		var sumfirst = 0.0
		for i in 0..<sizequotes {
			sumfirst = sumfirst + pow(firstquotes[i].exchangeRate - firstaverage, 2)
		}
		
		var sumsecond = 0.0
		for i in 0..<sizequotes {
			sumsecond = sumsecond + pow(secondquotes[i].exchangeRate - secondaverage, 2)
		}
		
		let denominator = pow(sumfirst + sumsecond, 0.5)

		let correl = cov/denominator
		if correl.isNaN {
			return 0.0
		} else {
			return correl
		}
	}
}
extension CorrelationVC: UITableViewDelegate, UITableViewDataSource, quoteCellDeleteDelegate {
	func deleteCell(instrument: String) {
		instrumentCorrelations.removeAll { (instrumentCorrel) -> Bool in
			return instrumentCorrel.instrument == instrument
		}
		quotestable.reloadData()
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return instrumentCorrelations.count
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.quoteCell, for: indexPath) as? quoteCell  {
			cell.delegate = self
			cell.configureCell(instrumentcor: instrumentCorrelations[indexPath.row])
			return cell
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		var height = tableView.frame.height
		height = height/4
		return CGFloat(exactly: height)!
	}
}
