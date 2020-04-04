//
//   incomeAssetAndPortfolio.swift
//  graphs
//
//  Created by Danila Ferents on 02.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import Foundation

class IncomeAssetAndPortfolioApi {
	
	func getIncomeForAssetFromTradesAndTransactionsAndQuotes(trades: [Trade],
															 transactions: [Transaction],
															 quotes: [Quote],
															 duration: DurationAssets,
															 currency: String,
															 start: Date,
															 end: Date) -> [(TimeInterval, Double)] {
		var assets: [(TimeInterval, Double)] = []

		var calendar = Calendar(identifier: .iso8601)
		guard let timezone = TimeZone(secondsFromGMT: 0) else {
			print("Error in unwrapping Timezone")
			return []
		}
		calendar.timeZone = timezone
		var dateComponents = DateComponents()
//		print(end)
		let startdateComponents = calendar.date(bySettingHour: 00, minute: 00, second: 00, of: start) ?? Date()
//		print(startdateComponents)
		var enddateComponents = calendar.date(bySettingHour: 00, minute: 00, second: 00, of: end) ?? Date()
		enddateComponents = calendar.date(byAdding: .day, value: 1, to: enddateComponents) ?? Date()
//		print(enddateComponents)
		var countComponents = 0
		switch duration {
		case .day:
			dateComponents = Calendar.current.dateComponents([.day], from: startdateComponents, to: enddateComponents)
			countComponents = dateComponents.day ?? 0
		case .month:
			dateComponents = Calendar.current.dateComponents([.month], from: startdateComponents, to: enddateComponents)
			countComponents = dateComponents.month ?? 0
		case .year:
			dateComponents = Calendar.current.dateComponents([.year], from: startdateComponents, to: enddateComponents)
			countComponents = dateComponents.year ?? 0
		}

		var filteredtrades: [Trade] = trades.filter {
			$0.dateTime >= startdateComponents &&
				$0.dateTime < enddateComponents &&
				($0.tradedPriceCurrency.uppercased() == currency.uppercased() || $0.tradedQuantityCurrency.uppercased() == currency.uppercased())
		}
		
		filteredtrades = filteredtrades.sorted { (firsttrade, secondtrade) -> Bool in
			if firsttrade.dateTime == secondtrade.dateTime {
				return firsttrade.id > secondtrade.id
			}
			return firsttrade.dateTime < secondtrade.dateTime
		}

		var filteredtransactions: [Transaction] = transactions.filter {
			$0.transactionStatus == "Complete" &&
				$0.dateTime >= startdateComponents &&
				$0.dateTime < enddateComponents &&
				($0.currency.uppercased() == currency.uppercased())
		}

		filteredtransactions = filteredtransactions.sorted { (firsttransaction, secondtransaction) -> Bool in
			if firsttransaction.dateTime == secondtransaction.dateTime {
				return firsttransaction.id > secondtransaction.id
			}
			return firsttransaction.dateTime < secondtransaction.dateTime
		}
		print(filteredtransactions)
		print(filteredtrades)
		var tradeindex = 0, transactionindex = 0
		var income = 0.0
		var interval = 0
		var currentdate = startdateComponents

		for _ in 0..<filteredtransactions.count + filteredtrades.count {

//			print("currentdate: ", currentdate)
//			if transactionindex < filteredtransactions.count {
//				print("transaction", filteredtransactions[transactionindex].dateTime)
//			}
//			if tradeindex < filteredtrades.count {
//				print("trades", filteredtrades[tradeindex].dateTime)
//			}
			while ((tradeindex	< filteredtrades.count &&
				transactionindex < filteredtransactions.count &&
				currentdate <= filteredtrades[tradeindex].dateTime &&
				currentdate <= filteredtransactions[transactionindex].dateTime) ||
				(tradeindex >= filteredtrades.count &&
					transactionindex < filteredtransactions.count &&
					currentdate <= filteredtransactions[transactionindex].dateTime) ||
				(transactionindex >= filteredtransactions.count &&
					tradeindex < filteredtrades.count &&
					currentdate <= filteredtrades[tradeindex].dateTime)) &&
				interval <= countComponents {

					interval += 1
					assets.append((currentdate.timeIntervalSince1970, income))
					income = 0
//					print(Date(timeIntervalSince1970: currentdate.timeIntervalSince1970))
					switch duration {
					case .day:
						currentdate = Calendar.current.date(byAdding: .day, value: interval, to: startdateComponents) ?? Date()
					case .month:
						currentdate = Calendar.current.date(byAdding: .month, value: interval, to: startdateComponents) ?? Date()
					case .year:
						currentdate = Calendar.current.date(byAdding: .year, value: interval, to: startdateComponents) ?? Date()
					}
			}

			let quote = quotes[interval]
			if transactionindex < filteredtransactions.count && tradeindex < filteredtrades.count {
				if filteredtransactions[transactionindex].dateTime <= filteredtrades[tradeindex].dateTime {
					processTransaction(transaction: filteredtransactions[transactionindex], income: &income, quote: quote)
					transactionindex += 1
				} else {
					processTrade(trade: filteredtrades[tradeindex], income: &income, quote: quote, currency: currency)
					tradeindex += 1
				}
			} else if transactionindex >= filteredtransactions.count {
				processTrade(trade: filteredtrades[tradeindex], income: &income, quote: quote, currency: currency)
				tradeindex += 1
			} else if tradeindex >= filteredtrades.count {
				processTransaction(transaction: filteredtransactions[transactionindex], income: &income, quote: quote)
				transactionindex += 1
			}

		}

		while currentdate <= enddateComponents && interval <= countComponents {

			interval += 1
			assets.append((currentdate.timeIntervalSince1970, income))
			income = 0
			switch duration {
			case .day:
				currentdate = Calendar.current.date(byAdding: .day, value: interval, to: startdateComponents) ?? Date()
			case .month:
				currentdate = Calendar.current.date(byAdding: .month, value: interval, to: startdateComponents) ?? Date()
			case .year:
				currentdate = Calendar.current.date(byAdding: .year, value: interval, to: startdateComponents) ?? Date()
			}
		}
		return assets
	}

	func processTrade(trade: Trade, income: inout Double, quote: Quote, currency: String) {
		if trade.tradedQuantityCurrency.uppercased() == currency.uppercased() {
			if trade.tradeType == "Buy" {
				income += (trade.tradedQuantity - trade.commission) * quote.exchangeRate
			} else if trade.tradeType == "Sell" {
				income -= trade.tradedQuantity * quote.exchangeRate
			}
		} else if trade.tradedPriceCurrency.uppercased() == currency.uppercased() {
			if trade.tradeType == "Buy" {
				income -= trade.tradedQuantity * trade.tradedPrice * quote.exchangeRate
			} else if trade.tradeType == "Sell" {
				income += (trade.tradedQuantity * trade.tradedPrice - trade.commission) * quote.exchangeRate
			}
		}
	}

	func processTransaction(transaction: Transaction, income: inout Double, quote: Quote) {
		if transaction.transactionType == "Deposit" {
			income -= (transaction.amount + transaction.commission) * quote.exchangeRate
		} else if transaction.transactionType == "Withdraw" {
			income += (transaction.amount - transaction.commission) * quote.exchangeRate
		}
	}
}
