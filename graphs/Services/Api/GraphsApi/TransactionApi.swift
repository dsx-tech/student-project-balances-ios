//
//  TransactionApi.swift
//  graphs
//
//  Created by Danila Ferents on 06.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import Foundation
import KeychainAccess

class TransactionApi {

	///get data for chart from transactions
	func getDatafromTransactions(transactions: inout [Transaction],
								 quotes: [String: [QuotePeriod]],
								 interval: Calendar.Component,
								 start: Date,
								 end: Date) -> [Date: (Double, Double)] {

		//dictionary with dates from start to end with interval where value is (input, outcome)
		var dateWithdrawDeposit: [Date: (Double, Double)] = [:]
		//number of intervals
		guard var numberOfComponents = Calendar.current.dateComponents([interval], from: start, to: end).value(for: interval) else { return [:] }

		let calendar = getGMTCalendar()

		//make new date from start with interval granularity
		var components = DateComponents()
		switch interval {
		case .year:
			components = calendar.dateComponents([.year], from: start)
		case .month:
			components = calendar.dateComponents([.year, .month], from: start)
		case .day:
			components = calendar.dateComponents([.year, .month, .day], from: start)
		default: break
		}
		//		print(start)
		guard let newstart = calendar.date(from: components) else {
			print("Error in ", #function, "with getting date from dateComponents.")
			return [:]

		}
//		print(newstart)
		//add xAxis components (Data from start to end with interval)
		var dateComponents = DateComponents()

		numberOfComponents += 1

		for i in 0...numberOfComponents {

			dateComponents.setValue(i, for: interval)

			let newdate = Calendar.current.date(byAdding: dateComponents, to: newstart) ?? Date()

			dateWithdrawDeposit[newdate] = (0, 0)
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

		let keychain = Keychain(service: "swagger")
		let baseCurrency = try? keychain.get("base_currency")

		transactions.forEach { (transaction) in
			if transaction.dateTime > start && transaction.dateTime < end {
				if let quotesAsset = quotes[transaction.currency + "-" + (baseCurrency ?? "usd")] {
					processTransaction(transaction: transaction, quotes: quotesAsset, dateWithdrawDeposit: &dateWithdrawDeposit, interval: interval)
				} else if let quote = currencies1[transaction.currency] {
					processTransaction(transaction: transaction,
									   quotes: [QuotePeriod(exchangeRate: quote, timestamp: 0)],
									   dateWithdrawDeposit: &dateWithdrawDeposit,
									   interval: interval)
				}

			}
		}

		return dateWithdrawDeposit
	}

	func processTransaction(transaction: Transaction, quotes: [QuotePeriod], dateWithdrawDeposit: inout [Date: (Double, Double)], interval: Calendar.Component) {

		let calendar = getGMTCalendar()
		var components = DateComponents()
		var index = 0

		switch interval {
		case .year:
			components = calendar.dateComponents([.year], from: transaction.dateTime)
			index = components.year ?? 0
		case .month:
			components = calendar.dateComponents([.year, .month], from: transaction.dateTime)
			index = components.month ?? 0
		case .day:
			components = calendar.dateComponents([.year, .month, .day], from: transaction.dateTime)
			index = components.day ?? 0
		default: break
		}
		if quotes.count == 1 {
			index = 0
		}
		guard let transactiondatewithgranularity = calendar.date(from: components) else {
			print("Error in ", #function, "with getting date from dateComponents.")
			return
		}
		//		print(transaction.dateTime)
		print(transactiondatewithgranularity)
		let currency = quotes[index]
		if transaction.transactionType == "Deposit" {
			if let currentdepositbalance = dateWithdrawDeposit[transactiondatewithgranularity] {
				dateWithdrawDeposit.updateValue((currentdepositbalance.0 + transaction.amount * currency.exchangeRate, 0), forKey: transactiondatewithgranularity)
			} else {
//				print(transactiondatewithgranularity)
//				print(transaction.dateTime)
				dateWithdrawDeposit.updateValue((transaction.amount * currency.exchangeRate, 0), forKey: transactiondatewithgranularity)
			}
		} else if transaction.transactionType == "Withdraw" {
			if let currentwithdrawbalance = dateWithdrawDeposit[transactiondatewithgranularity] {
				dateWithdrawDeposit.updateValue((0,
												 currentwithdrawbalance.1 + transaction.amount * currency.exchangeRate),
												forKey: transactiondatewithgranularity)
			} else {
				dateWithdrawDeposit.updateValue((0, transaction.amount * currency.exchangeRate), forKey: transactiondatewithgranularity)
			}
		}
	}

	func getGMTCalendar() -> Calendar {

		var calendar = Calendar(identifier: .iso8601)
		guard let timezone = TimeZone(secondsFromGMT: 0) else {
			print("Error in unwrapping Timezone")
			return calendar
		}
		calendar.timeZone = timezone

		return calendar
	}
}
