//
//  ActiveCostApi.swift
//  graphs
//
//  Created by Danila Ferents on 31.03.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import Foundation
import KeychainAccess

class ActiveCostAndPieApi {

	// Make class Singleton
	static let sharedManager = ActiveCostAndPieApi()

	private init() {
	}

	func getAssetsForActiveCost(trades: inout [Trade],
								transactions: inout  [Transaction],
								start: String,
								end: String,
								duration: AssetLineChartDuration) -> ([String: ([Double], [Double])], Set<String>) {

		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		var calendar = Calendar(identifier: .iso8601)
		guard let timezone = TimeZone(secondsFromGMT: 0) else {
			print("Error in unwrapping Timezone")
			return (([:], []))
		}
		calendar.timeZone = timezone

		var dateComponents = DateComponents()

		let start = formatter.date(from: start) ?? Date()
		let end = formatter.date(from: end) ?? Date()

		let startdateComponents = calendar.date(bySettingHour: 00, minute: 00, second: 00, of: start) ?? Date()

		var enddateComponents = calendar.date(bySettingHour: 00, minute: 00, second: 00, of: end) ?? Date()

		enddateComponents = calendar.date(byAdding: .day, value: 1, to: enddateComponents) ?? Date()

		var countComponents = 0

		var assetsDuration: [String: ([Double], [Double])] = [:]

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

		countComponents += 1

		for i in 0..<countComponents {

			switch duration {
			case .day:
				dateComponents.day = i
			case .month:
				dateComponents.month = i
			default:
				dateComponents.year = i
			}

			guard let newdate = Calendar.current.date(byAdding: dateComponents, to: startdateComponents) else { return ([:], []) }

			let (assets, _) = getAssetsFromTradesAndTransactions(trades: &trades, transactions: &transactions, start: Date(timeIntervalSince1970: 0), end: newdate)

			for (key, value) in assets {
				if assetsDuration[key] !=  nil {
					if newdate < start || newdate > end {
						continue
					}
					assetsDuration[key]?.0.append(value)
					assetsDuration[key]?.1.append(newdate.timeIntervalSince1970)
				} else {
					if newdate < start || newdate > end {
						continue
					}
					assetsDuration[key] = ([value], [newdate.timeIntervalSince1970])
				}
			}
		}
		var currencies: Set<String> = []

		for (key, _) in assetsDuration {
			currencies.insert(key)
		}
		return (assetsDuration, currencies)
	}

	func getAssetsForActiveCostWithQuotes(assets: [String: ([Double], [Double])],
										  quotes: [String: [QuotePeriod]]) -> [String: ([Double], [Double])] {
		let keychain = Keychain(service: "swagger")
		let baseCurrency = try? keychain.get("base_currency")

		guard let newbasecurrency = baseCurrency else { return [:] }

		var newassets: [String: ([Double], [Double])] = assets

		for (key, value) in assets {
			var newvalues: [Double] = []
			if let currencyarray = quotes[key + "-" + newbasecurrency] {
				for i in 0..<value.0.count {
					newvalues.append(value.0[i]*currencyarray[i].exchangeRate)
				}
			} else if let currency = currencies1[key] {
				print("Why here!")
				for i in 0..<value.0.count {
					newvalues.append(value.0[i]*currency)
				}
				newassets[key]?.0 = newvalues
			}
		}

		return newassets
	}

	func getAssetsForPie(trades: inout [Trade], transactions: inout  [Transaction]) -> ([String: Double], [String]) {

		let (assets, _) = getAssetsFromTradesAndTransactions(trades: &trades,
															 transactions: &transactions,
															 start: Date(timeIntervalSince1970: 0),
															 end: Date(timeIntervalSinceNow: 0))
		var currencies: [String] = []

		for (key, _) in assets {
			currencies.append(key)
		}
		return (assets, currencies)
	}

	func getAssetsForPieWithQuotes(assets: [String: Double], quotes: [String: [Quote]]) -> [(String, Double)] {

		let keychain = Keychain(service: "swagger")
		let baseCurrency = try? keychain.get("base_currency")

		guard let newbasecurrency = baseCurrency else { return [] }

		var newassets: [(String, Double)] = []

		for (key, value) in assets {
			if let currencyarray = quotes[key + "-" + newbasecurrency], let currency = currencyarray.first {
				newassets.append((key, value * currency.exchangeRate))
			} else if let currency = currencies1[key] {
				print("Why here!")
				newassets.append((key, value * currency))
			}
		}

		return newassets
	}

	func getAssetsInDurationForStack(trades: inout [Trade],
									 transactions: inout [Transaction],
									 duration: AssetLineChartDuration,
									 start: String,
									 end: String) -> ([(Date, [Double])], [String]) {

		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		var calendar = Calendar(identifier: .iso8601)
		guard let timezone = TimeZone(secondsFromGMT: 0) else {
			print("Error in unwrapping Timezone")
			return ([], [])
		}
		calendar.timeZone = timezone
		var dateComponents = DateComponents()

		let start = formatter.date(from: start) ?? Date()
		let end = formatter.date(from: end) ?? Date()

		let startdateComponents = calendar.date(bySettingHour: 00, minute: 00, second: 00, of: start) ?? Date()

		var enddateComponents = calendar.date(bySettingHour: 00, minute: 00, second: 00, of: end) ?? Date()

		enddateComponents = calendar.date(byAdding: .day, value: 1, to: enddateComponents) ?? Date()

		var countComponents = 0

		switch duration {
		case.day:
			print("Error! Not appropriate duration.")
		case .month:
			dateComponents = Calendar.current.dateComponents([.month], from: startdateComponents, to: enddateComponents)
			countComponents = dateComponents.month ?? 0
		case .year:
			dateComponents = Calendar.current.dateComponents([.year], from: startdateComponents, to: enddateComponents)
			countComponents = dateComponents.year ?? 0
		}

		countComponents += 1

		var assetsInDuration: [(Date, [Double])] = []
		var labels: [String] = []

		for i in 0..<countComponents {
			switch duration {
			case .day:
				print("Error! Not appropriate duration.")
			case .month:
				dateComponents.month = i
			default:
				dateComponents.year = i
			}

			guard let newdate = Calendar.current.date(byAdding: dateComponents, to: startdateComponents) else { return ([], []) }

			let (assets, _) = ActiveCostAndPieApi.sharedManager.getAssetsFromTradesAndTransactions(
				trades: &trades,
				transactions: &transactions,
				start: Date(timeIntervalSince1970: 0),
				end: newdate)

			let sortedassets = assets.sorted { $0.key < $1.key }

			var assetsNames: [String] = []
			var assetsValues: [Double] = []

			for (key, value) in sortedassets where value >= 0 {
					assetsNames.append(key)
					if let currency = currencies1[key] {
						assetsValues.append(value * currency)
				}
			}
			if assetsNames.count > labels.count {
				labels = assetsNames
			}
			assetsInDuration.append((newdate, assetsValues))
		}
		return (assetsInDuration, labels)
	}

	func changeAssetsInDurationForStack(trades: inout [Trade],
									 transactions: inout [Transaction],
									 duration: AssetLineChartDuration,
									 start: String,
									 end: String) -> ([(Date, [(String, Double)])], [String]) {

		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		var calendar = Calendar(identifier: .iso8601)
		guard let timezone = TimeZone(secondsFromGMT: 0) else {
			print("Error in unwrapping Timezone")
			return ([], [])
		}
		calendar.timeZone = timezone
		var dateComponents = DateComponents()

		let start = formatter.date(from: start) ?? Date()
		let end = formatter.date(from: end) ?? Date()

		let startdateComponents = calendar.date(bySettingHour: 00, minute: 00, second: 00, of: start) ?? Date()

		var enddateComponents = calendar.date(bySettingHour: 00, minute: 00, second: 00, of: end) ?? Date()

		enddateComponents = calendar.date(byAdding: .day, value: 1, to: enddateComponents) ?? Date()

		var countComponents = 0

		switch duration {
		case.day:
			print("Error! Not appropriate duration.")
		case .month:
			dateComponents = Calendar.current.dateComponents([.month], from: startdateComponents, to: enddateComponents)
			countComponents = dateComponents.month ?? 0
		case .year:
			dateComponents = Calendar.current.dateComponents([.year], from: startdateComponents, to: enddateComponents)
			countComponents = dateComponents.year ?? 0
		}

		countComponents += 1

		var assetsInDuration: [(Date, [(String, Double)])] = []
		var labels: [String] = []

		for i in 0..<countComponents {
			switch duration {
			case .day:
				print("Error! Not appropriate duration.")
			case .month:
				dateComponents.month = i
			default:
				dateComponents.year = i
			}

			guard let newdate = Calendar.current.date(byAdding: dateComponents, to: startdateComponents) else { return ([], []) }

			let (assets, _) = ActiveCostAndPieApi.sharedManager.getAssetsFromTradesAndTransactions(
				trades: &trades,
				transactions: &transactions,
				start: Date(timeIntervalSince1970: 0),
				end: newdate)

			let sortedassets = assets.sorted { $0.key < $1.key }

			var assetsNames: [String] = []
			var assetsValues: [(String, Double)] = []

			for (key, value) in sortedassets where value >= 0 {
					assetsNames.append(key)
//					if let currency = currencies1[key] {
						assetsValues.append((key, value))
//				}
			}
			if assetsNames.count > labels.count {
				labels = assetsNames
			}
			assetsInDuration.append((newdate, assetsValues))
		}
		return (assetsInDuration, labels)
	}

	func getAssetsInDurationForStackQuotes(assets: [(Date, [(String, Double)])], quotes: [String: [QuotePeriod]]) -> [(Date, [(String, Double)])] {

		let keychain = Keychain(service: "swagger")
		let baseCurrency = try? keychain.get("base_currency")

		guard let newbasecurrency = baseCurrency else { return [] }

		var newassets = assets

		for i in 0..<newassets.count {
			for j in 0..<newassets[i].1.count {
				if let quotes = quotes[newassets[i].1[j].0 + "-" + newbasecurrency] {
					newassets[i].1[j].1 *= quotes[i].exchangeRate
				} else if let cuurency = currencies1[newassets[i].1[j].0] {
					print("Why here!")
					newassets[i].1[j].1 *= cuurency
				}
			}
		}

		return newassets
	}

	func getAssetsFromTradesAndTransactions(trades: inout [Trade],
											transactions: inout [Transaction],
											start: Date,
											end: Date) -> ([String: Double], [(String, String, String)]) {

		var strangeIds: [(String, String, String)] = []
		var assets: [String: Double] = [:]

		trades.sort { (firsttrade, secondtrade) -> Bool in
			if firsttrade.dateTime == secondtrade.dateTime {
				return firsttrade.id > secondtrade.id
			}
			return firsttrade.dateTime < secondtrade.dateTime
		}

		transactions.sort { (firsttransaction, secondtransaction) -> Bool in
			if firsttransaction.dateTime == secondtransaction.dateTime {
				return firsttransaction.id > secondtransaction.id
			}
			return firsttransaction.dateTime < secondtransaction.dateTime
		}

		transactions = transactions.filter {
			$0.transactionStatus == "Complete"
		}

		var tradeindex = 0, transactionindex = 0

		for _ in 0..<trades.count + transactions.count {

			//case when all trades are processed or trade's date does not conform
			if tradeindex < trades.count && (trades[tradeindex].dateTime < start || trades[tradeindex].dateTime > end) {
				tradeindex += 1
				continue
			}

			//case when all transactions are processed or transaction's date does not conform
			if transactionindex < transactions.count && (transactions[transactionindex].dateTime < start || transactions[transactionindex].dateTime > end) {
				transactionindex += 1
				continue
			}

			if transactionindex < transactions.count && tradeindex < trades.count {

				if transactions[transactionindex].dateTime <= trades[tradeindex].dateTime {
					processTransaction(transaction: transactions[transactionindex], assets: &assets, strangeIds: &strangeIds)
					transactionindex += 1
				} else {
					processTrade(trade: trades[tradeindex], assets: &assets, strangeIds: &strangeIds)
					tradeindex += 1
				}
			} else if transactionindex >= transactions.count {
				processTrade(trade: trades[tradeindex], assets: &assets, strangeIds: &strangeIds)
				tradeindex += 1
			} else if tradeindex >= trades.count {
				processTransaction(transaction: transactions[transactionindex], assets: &assets, strangeIds: &strangeIds)
				transactionindex += 1
			}

		}
		return (assets, strangeIds)
	}

	func processTrade(trade: Trade, assets: inout [String: Double], strangeIds: inout [(String, String, String)]) {

		var deductibleQuantity: Double = 0
		var addedQuantity: Double = 0
		var deductibleCurrency: String = ""
		var addedCurrency: String = ""

		if trade.tradeType == "Sell" {
			deductibleCurrency = trade.tradedQuantityCurrency
			deductibleQuantity = trade.tradedQuantity
			addedCurrency = trade.tradedPriceCurrency
			addedQuantity = trade.tradedPrice * trade.tradedQuantity
		} else if trade.tradeType == "Buy" {
			deductibleCurrency = trade.tradedPriceCurrency
			deductibleQuantity = trade.tradedPrice * trade.tradedQuantity
			addedCurrency = trade.tradedQuantityCurrency
			addedQuantity = trade.tradedQuantity
		}

		if let currentassetQuantity = assets[deductibleCurrency] {
			if currentassetQuantity < deductibleQuantity {
				strangeIds.append(("Trade", trade.tradeValueId, deductibleCurrency)) }
			assets[deductibleCurrency]? -= deductibleQuantity
		} else {
			assets[deductibleCurrency] = -deductibleQuantity
			strangeIds.append(("Trade", trade.tradeValueId, deductibleCurrency))
		}

		if assets[addedCurrency] != nil {
			assets[addedCurrency]? += addedQuantity
		} else {
			assets[addedCurrency] = addedQuantity
		}
		if assets[trade.commissionCurrency] != nil {
			assets[trade.commissionCurrency]? -= trade.commission
		} else {
			assets[trade.commissionCurrency] = -trade.commission
		}
		//				print(assets, trade.id)
	}

	func processTransaction(transaction: Transaction, assets: inout [String: Double], strangeIds: inout [(String, String, String)]) {

		if transaction.transactionType == "Withdraw" {
			if let currentassetQuantity = assets[transaction.currency] {
				if currentassetQuantity < transaction.amount {
					strangeIds.append(("Transaction", transaction.transactionValueId, transaction.currency))
				}
				assets[transaction.currency]? -= transaction.amount
			} else {
				assets[transaction.currency] = -transaction.amount
				strangeIds.append(("Transaction", transaction.transactionValueId, transaction.currency))
			}
		} else if transaction.transactionType == "Deposit" {
			if assets[transaction.currency] != nil {
				assets[transaction.currency]? += transaction.amount
			} else {
				assets[transaction.currency] = transaction.amount
			}
		}
		assets[transaction.currency]? -= transaction.commission
		//		print(assets, transaction.id)
	}

}
