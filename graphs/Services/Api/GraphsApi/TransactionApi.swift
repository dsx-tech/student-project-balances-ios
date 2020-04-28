//
//  TransactionApi.swift
//  graphs
//
//  Created by Danila Ferents on 06.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import Foundation

class TransactionApi {

	///get data for chart from transactions
	func getDatafromTransactions(transactions: inout [Transaction], interval: Calendar.Component, start: Date, end: Date) -> [Date: (Double, Double)] {

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

		transactions.forEach { (transaction) in
			if transaction.dateTime > start && transaction.dateTime < end {
				processTransaction(transaction: transaction, dateWithdrawDeposit: &dateWithdrawDeposit, interval: interval)
			}
		}

		return dateWithdrawDeposit
	}

	func processTransaction(transaction: Transaction, dateWithdrawDeposit: inout [Date: (Double, Double)], interval: Calendar.Component) {

		let calendar = getGMTCalendar()
		var components = DateComponents()

		switch interval {
		case .year:
			components = calendar.dateComponents([.year], from: transaction.dateTime)
		case .month:
			components = calendar.dateComponents([.year, .month], from: transaction.dateTime)
		case .day:
			components = calendar.dateComponents([.year, .month, .day], from: transaction.dateTime)
		default: break
		}

		guard let transactiondatewithgranularity = calendar.date(from: components) else {
			print("Error in ", #function, "with getting date from dateComponents.")
			return
		}
		//		print(transaction.dateTime)
		print(transactiondatewithgranularity)
		if transaction.transactionType == "Deposit" {
			if let currentdepositbalance = dateWithdrawDeposit[transactiondatewithgranularity] {
				guard let currency = currencies1[transaction.currency] else { return }
				dateWithdrawDeposit.updateValue((currentdepositbalance.0 + transaction.amount * currency, 0), forKey: transactiondatewithgranularity)
			} else {
//				print(transactiondatewithgranularity)
//				print(transaction.dateTime)
				guard let currency = currencies1[transaction.currency] else { return }
				dateWithdrawDeposit.updateValue((transaction.amount * currency, 0), forKey: transactiondatewithgranularity)
			}
		} else if transaction.transactionType == "Withdraw" {
			if let currentwithdrawbalance = dateWithdrawDeposit[transactiondatewithgranularity] {
				guard let currency = currencies1[transaction.currency] else { return }
				dateWithdrawDeposit.updateValue((0,
												 currentwithdrawbalance.1 + transaction.amount * currency),
												forKey: transactiondatewithgranularity)
			} else {
				guard let currency = currencies1[transaction.currency] else { return }
				dateWithdrawDeposit.updateValue((0, transaction.amount * currency), forKey: transactiondatewithgranularity)
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
