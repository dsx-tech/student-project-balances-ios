//
//  CorellationVC.swift
//  graphs
//
//  Created by Danila Ferents on 16.02.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import KeychainAccess

class CorrelationVC: UIViewController {
	
	//Variables
	var instrumentCorrelations: [(String, [InstrumentCorrelation])] = []
	var quotes: [(String, [QuotePeriod])] = []
	let quotesApi = TradeApi()
	let syncCoordinator = SyncCoordinator()

	@IBOutlet weak var quotestable: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		instrumentCorrelations = [("eur",
//								   [InstrumentCorrelation(firstCurrency: "btc", secondCurrency: "usd", correlation: 0.138, timePeriod: "3 months"),
//									InstrumentCorrelation(firstCurrency: "eurs", secondCurrency: "usd", correlation: -0.5, timePeriod: "1 month"),
//									InstrumentCorrelation(firstCurrency: "btg", secondCurrency: "usd", correlation: 0.837, timePeriod: "6 months")]),
//								  ("btc", [InstrumentCorrelation(firstCurrency: "bsv", secondCurrency: "usd", correlation: 0.038, timePeriod: "3 months")])]
		setUpTableView()

		let formatter = DateFormatter()
		
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		
		guard let start = formatter.date(from: "2019-01-01T00:00:01") else { return }
		
		callculatecorrelation(firstinstrument: "eur", secondinstrument: "btc", startDate: start, duration: .month)
	}
}

// - MARK: setUpfunctions

extension CorrelationVC {
	func setUpTableView() {
		quotestable.delegate = self
		quotestable.register(UINib(nibName: "quoteCell", bundle: nil), forCellReuseIdentifier: Identifiers.quoteCell)
		quotestable.dataSource = self
	}
}

// - MARK: Correlation

extension CorrelationVC {
	
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
	func callculatecorrelation(firstinstrument: String, secondinstrument: String, startDate: Date, duration: DurationQuotes) {

		//number of months to count corellation, which we take from duration parameter
		var dateComponents = DateComponents()
		switch duration {
		case .month:
			dateComponents.month = 1
		case .threemonths:
			dateComponents.month = 3
		case .sixmonths:
			dateComponents.month = 6
		case .year:
			dateComponents.month = 12
		}

		guard let enddate = Calendar.current.date(byAdding: dateComponents, to: startDate) else {
			print("Error in converting end date.")
			return
		}

		let keychain = Keychain(service: "swagger")
		let baseCurrency = try? keychain.get("base_currency")

		let firstinstrumentWithBase = firstinstrument + "-" + (baseCurrency ?? "usd")
		let secondinstrumentWithBase = secondinstrument + "-" + (baseCurrency ?? "usd")

		self.syncCoordinator.getAndSyncQuotesInPeriod(assets: [firstinstrumentWithBase, secondinstrumentWithBase],
													  start: startDate,
													  end: enddate,
													  duration: "daily") { (quotes) in

			guard let quotesArray = quotes,
				let firstQuotes = quotesArray[firstinstrumentWithBase],
				let secondQuotes = quotesArray[secondinstrumentWithBase] else {
					DispatchQueue.main.async {
						self.simpleAlert(title: "Error", msg: "No such quotes!")
					}
					print("Error in getting quotes for instrument")
					return
			}
			DispatchQueue.main.async {
				self.quotes.append((firstinstrument, firstQuotes))
				self.quotes.append((secondinstrument, secondQuotes))
			}

			let correl = InstrumentCorrelation(firstCurrency: secondinstrument,
											   secondCurrency: baseCurrency ?? "usd",
											   correlation: CorrelationApi.sharedManager.correlationQuotes(firstquotes: firstQuotes, secondquotes: secondQuotes),
											   timePeriod: "months: \(dateComponents.month ?? 0)")
			//				self.instrumentCorrelations.append(correl)
			DispatchQueue.main.async {
				if let firstInstrumentIndex = self.instrumentCorrelations.firstIndex(where: { (element) -> Bool in
					return element.0 == firstinstrument
				}) {
					self.instrumentCorrelations[firstInstrumentIndex].1.append(correl)
				} else {
					self.instrumentCorrelations.append((firstinstrument, [correl]))
				}
			}
//			print(self.instrumentCorrelations)
			DispatchQueue.main.async {
				self.quotestable.reloadData()
			}
		}
	}
}

// - MARK: UITableViewDelegate, UITableViewDataSource

extension CorrelationVC: UITableViewDelegate, UITableViewDataSource {

	func processGraph(secondInstrument: String, indexPath: IndexPath) {
		performSegue(withIdentifier: Segues.toGraph, sender: (secondInstrument, indexPath))
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return instrumentCorrelations[section].1.count
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return instrumentCorrelations.count
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return instrumentCorrelations[section].0
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.quoteCell, for: indexPath) as? QuoteCell {
			cell.delegate = self
			cell.configureCell(instrumentcor: instrumentCorrelations[indexPath.section].1[indexPath.row],
							   maininstrument: instrumentCorrelations[indexPath.section].0,
							   indexPath: indexPath)
			return cell
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		var height = tableView.frame.height
		height /= 5
		guard let float = CGFloat(exactly: height) else { return CGFloat() }
		return float
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? AddIInstrumentVC {
			vc.vc = self
		} else if let graphVC = segue.destination as? CorrelationGraphVC {
			if let sender = sender as? (String, IndexPath) {

				graphVC.firstInstrument = instrumentCorrelations[sender.1.section].0
				graphVC.secondInstrument = instrumentCorrelations[sender.1.section].1.compactMap({ (instrumentCorrel) -> String? in
					return instrumentCorrel.firstCurrency
				})

				graphVC.secondQuotes = quotes.first(where: { (element) -> Bool in
					return element.0 == sender.0
				})?.1
				graphVC.firstQuotes = quotes.first(where: { (element) -> Bool in
					return element.0 == instrumentCorrelations[sender.1.section].0
				})?.1
			}
			graphVC.vc = self
		}
	}
}

// - MARK: quoteCellDeleteDelegate

extension CorrelationVC: quoteCellDeleteDelegate {
	func deleteCell(instrument1: String, instrument2: String, indexPath: IndexPath) {
		self.instrumentCorrelations[indexPath.section].1.remove(at: indexPath.row)
		quotestable.reloadData()
	}
}
