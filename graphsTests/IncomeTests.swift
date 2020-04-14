//
//  IncomeTests.swift
//  graphsTests
//
//  Created by Danila Ferents on 02.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import XCTest

class IncomeTests: XCTestCase {

	var api: IncomeAssetAndPortfolioApi!

	override func setUp() {
		super.setUp()
		api = IncomeAssetAndPortfolioApi()
	}

	override func tearDown() {
		super.tearDown()
		api = nil
	}

	func testgetIncomeForAssetFromTradesAndTransactionsAndQuotes() {

		var trades: [Trade] = []

		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

		let result = [0,
					  0,
					  0,
					  0,
					  12.06315,
					  6.62688,
					  3536.7275,
					  0,
					  0,
					  -0.252246
		]

		let quotes = [
			Quote(exchangeRate: 7419, timestamp: 0),
			Quote(exchangeRate: 8098, timestamp: 1574294400),
			Quote(exchangeRate: 7627, timestamp: 1574294400),
			Quote(exchangeRate: 7268, timestamp: 1574380800),
			Quote(exchangeRate: 7311, timestamp: 1574467200),
			Quote(exchangeRate: 6903, timestamp: 1574553600),
			Quote(exchangeRate: 7109, timestamp: 1574640000),
			Quote(exchangeRate: 7156, timestamp: 1574726400),
			Quote(exchangeRate: 7508, timestamp: 1574812800),
			Quote(exchangeRate: 7419, timestamp: 1574899200),
			Quote(exchangeRate: 7419, timestamp: 0)
		]

		trades.append(Trade(id: 0,
							dateTime: formatter.date(from: "2019-11-29T00:00:00Z") ?? Date(),
							instrument: "btc-usd",
							tradeType: "Sell",
							tradedQuantity: 0.1,
							tradedQuantityCurrency: "btc",
							tradedPrice: 6600,
							tradedPriceCurrency: "usd",
							commission: 0.08,
							commissionCurrency: "usd",
							tradeValueId: "14"))

		trades.append(Trade(id: 1,
							dateTime: formatter.date(from: "2019-11-28T23:59:59Z") ?? Date(),
							instrument: "usd-btc",
							tradeType: "Buy",
							tradedQuantity: 0.1,
							tradedQuantityCurrency: "usd",
							tradedPrice: 0.00034,
							tradedPriceCurrency: "btc",
							commission: 0.00005,
							commissionCurrency: "usd",
							tradeValueId: "13"))

		trades.append(Trade(id: 2,
							dateTime: formatter.date(from: "2019-11-25T02:59:59Z") ?? Date(),
							instrument: "btc-usd",
							tradeType: "Buy",
							tradedQuantity: 0.5,
							tradedQuantityCurrency: "btc",
							tradedPrice: 6700,
							tradedPriceCurrency: "usd",
							commission: 0.0025,
							commissionCurrency: "btc",
							tradeValueId: "12"))

		trades.append(Trade(id: 3,
							dateTime: formatter.date(from: "2019-11-24T21:00:00Z") ?? Date(),
							instrument: "ltc-eur",
							tradeType: "Sell",
							tradedQuantity: 0.001,
							tradedQuantityCurrency: "ltc",
							tradedPrice: 47.6,
							tradedPriceCurrency: "eur",
							commission: 0.0001,
							commissionCurrency: "eur",
							tradeValueId: "11"))
		trades.append(Trade(id: 4,
							dateTime: formatter.date(from: "2019-11-24T00:00:00Z") ?? Date(),
							instrument: "ltc-btc",
							tradeType: "Sell",
							tradedQuantity: 0.1,
							tradedQuantityCurrency: "ltc",
							tradedPrice: 0.0086,
							tradedPriceCurrency: "btc",
							commission: 0.0001,
							commissionCurrency: "btc",
							tradeValueId: "7"))

		trades.append(Trade(id: 5,
							dateTime: formatter.date(from: "2019-11-18T01:12:45Z") ?? Date(),
							instrument: "eos-btc",
							tradeType: "Buy",
							tradedQuantity: 1,
							tradedQuantityCurrency: "eos",
							tradedPrice: 0.00035,
							tradedPriceCurrency: "btc",
							commission: 0.00001,
							commissionCurrency: "eos",
							tradeValueId: "5"))

		trades.append(Trade(id: 6,
							dateTime: formatter.date(from: "2019-10-24T23:00:00Z") ?? Date(),
							instrument: "usd-eur",
							tradeType: "Sell",
							tradedQuantity: 0.001,
							tradedQuantityCurrency: "usd",
							tradedPrice: 1.2,
							tradedPriceCurrency: "eur",
							commission: 0.0001,
							commissionCurrency: "eur",
							tradeValueId: "4"))

		var transactions: [Transaction] = []

		transactions.append(Transaction(id: 0,
										dateTime: formatter.date(from: "2019-12-25T01:00:00Z") ?? Date(),
										amount: 0.027,
										currency: "ltc",
										transactionValueId: "16",
										transactionStatus: "Complete",
										transactionType: "Deposit",
										commission: 0.002))

		transactions.append(Transaction(id: 1,
										dateTime: formatter.date(from: "2019-11-29T20:30:00Z") ?? Date(),
										amount: 0.001,
										currency: "btc",
										transactionValueId: "15",
										transactionStatus: "Complete",
										transactionType: "Deposit",
										commission: 0.0001))

		transactions.append(Transaction(id: 2,
										dateTime: formatter.date(from: "2019-11-24T19:30:00Z") ?? Date(),
										amount: 10.96,
										currency: "usd",
										transactionValueId: "10",
										transactionStatus: "Complete",
										transactionType: "Withdraw",
										commission: 0.001))

		transactions.append(Transaction(id: 3,
										dateTime: formatter.date(from: "2019-11-24T18:30:00Z") ?? Date(),
										amount: 0.0003,
										currency: "btc",
										transactionValueId: "9",
										transactionStatus: "Complete",
										transactionType: "Withdraw",
										commission: 0.0001))

		transactions.append(Transaction(id: 4,
										dateTime: formatter.date(from: "2019-11-24T18:29:00Z") ?? Date(),
										amount: 0.0002,
										currency: "BTC",
										transactionValueId: "8",
										transactionStatus: "Failed",
										transactionType: "Withdraw",
										commission: 0.00005))

		transactions.append(Transaction(id: 5,
										dateTime: formatter.date(from: "2019-11-23T18:30:00Z") ?? Date(),
										amount: 0.002,
										currency: "btc",
										transactionValueId: "6",
										transactionStatus: "Complete",
										transactionType: "Withdraw",
										commission: 0.00035))

		transactions.append(Transaction(id: 6,
										dateTime: formatter.date(from: "2019-08-24T19:29:00Z") ?? Date(),
										amount: 10.96,
										currency: "BTC",
										transactionValueId: "3",
										transactionStatus: "Failed",
										transactionType: "Withdraw",
										commission: 0.00035))

		transactions.append(Transaction(id: 7,
										dateTime: formatter.date(from: "2019-08-24T19:28:00Z") ?? Date(),
										amount: 10.96,
										currency: "BTC",
										transactionValueId: "2",
										transactionStatus: "Complete",
										transactionType: "Withdraw",
										commission: 0.00035))

		transactions.append(Transaction(id: 8,
										dateTime: formatter.date(from: "2019-08-24T18:01:00Z") ?? Date(),
										amount: 0.001,
										currency: "BTC",
										transactionValueId: "1",
										transactionStatus: "Complete",
										transactionType: "Deposit",
										commission: 0.0001))

		transactions.append(Transaction(id: 9,
										dateTime: formatter.date(from: "2019-08-24T18:00:00Z") ?? Date(),
										amount: 0.001,
										currency: "btc",
										transactionValueId: "0",
										transactionStatus: "Failed",
										transactionType: "Deposit",
										commission: 0.0001))

		let assets = self.api.getIncomeForAssetFromTradesAndTransactionsAndQuotes(trades: trades,
																				  transactions: transactions,
																				  quotes: quotes,
																				  duration: .day,
																				  currency: "btc",
																				  start: Date(timeIntervalSince1970: 1574208000),
																				  end: Date(timeIntervalSince1970: 1574899200))
//		print(Date(timeIntervalSince1970: 1574208000))
//		print(Date(timeIntervalSince1970: 1574899200))
//		assets.forEach { (int, val) in
//			print(Date(timeIntervalSince1970: int), val)
//		}
//		quotes.forEach { (quote) in
//			print(Date(timeIntervalSince1970: TimeInterval(quote.timestamp)), quote.exchangeRate)
//		}
		var i = 0
		assets.forEach({ (_, value) in
			let digits = Double(String(value).count - String(Int(value)).count)
			XCTAssertEqual(value, result[i], accuracy: pow(0.1, digits))
			i += 1
		})
	}
}
