//
//  getAssetsForActiveCost.swift
//  
//
//  Created by Danila Ferents on 01.04.20.
//

import XCTest
@testable import graphs

class GetAssetsForActiveCost: XCTestCase {

		var api: ActiveCostAndPieApi!

		override func setUp() {
			super.setUp()
			api = ActiveCostAndPieApi()
		}

		override func tearDown() {
			super.tearDown()
			api = nil
		}

		func testgetAssetsFromTradesAndTransactions() {

			var trades: [Trade] = []

			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

			let result = ["EOS": 1.495 ,
						  "BTC": 0.000377,
						  "LTC": -0.07535,
						  "USD": -11.44935,
						  "EUR": 0.1974001]

			trades.append(Trade(id: 0,
								dateTime: formatter.date(from: "2019-11-25T03:00:00") ?? Date(),
								instrument: "eosbtc",
								tradeType: "Buy",
								tradedQuantity: 1,
								tradedQuantityCurrency: "EOS",
								tradedPrice: 0.00035,
								tradedPriceCurrency: "BTC",
								commission: 0.0025,
								commissionCurrency: "EOS",
								tradeValueId: "11"))

			trades.append(Trade(id: 1,
								dateTime: formatter.date(from: "2019-11-25T02:59:59") ?? Date(),
								instrument: "eosbtc",
								tradeType: "Buy",
								tradedQuantity: 0.5,
								tradedQuantityCurrency: "EOS",
								tradedPrice: 0.00034,
								tradedPriceCurrency: "BTC",
								commission: 0.0025,
								commissionCurrency: "EOS",
								tradeValueId: "10"))

			trades.append(Trade(id: 2,
								dateTime: formatter.date(from: "2019-11-24T23:00:00") ?? Date(),
								instrument: "btceur",
								tradeType: "Buy",
								tradedQuantity: 0.001,
								tradedQuantityCurrency: "BTC",
								tradedPrice: 277.3999,
								tradedPriceCurrency: "EUR",
								commission: 0.000003,
								commissionCurrency: "BTC",
								tradeValueId: "8"))

			trades.append(Trade(id: 3,
								dateTime: formatter.date(from: "2019-11-24T22:00:00") ?? Date(),
								instrument: "ltceur",
								tradeType: "Sell",
								tradedQuantity: 0.1,
								tradedQuantityCurrency: "LTC",
								tradedPrice: 2.359,
								tradedPriceCurrency: "EUR",
								commission: 0.01,
								commissionCurrency: "EUR",
								tradeValueId: "7"))

			trades.append(Trade(id: 4,
								dateTime: formatter.date(from: "2019-11-24T21:00:00") ?? Date(),
								instrument: "btceur",
								tradeType: "Sell",
								tradedQuantity: 0.001,
								tradedQuantityCurrency: "BTC",
								tradedPrice: 258.9,
								tradedPriceCurrency: "EUR",
								commission: 0.01,
								commissionCurrency: "EUR",
								tradeValueId: "6"))

			trades.append(Trade(id: 5,
								dateTime: formatter.date(from: "2019-11-24T20:00:00") ?? Date(),
								instrument: "ltcusd",
								tradeType: "Buy",
								tradedQuantity: 0.1,
								tradedQuantityCurrency: "LTC",
								tradedPrice: 249.7,
								tradedPriceCurrency: "USD",
								commission: 0.00035,
								commissionCurrency: "LTC",
								tradeValueId: "4"))

			trades.append(Trade(id: 6,
								dateTime: formatter.date(from: "2019-11-24T19:00:00") ?? Date(),
								instrument: "ltcusd",
								tradeType: "Sell",
								tradedQuantity: 0.1,
								tradedQuantityCurrency: "LTC",
								tradedPrice: 245.61,
								tradedPriceCurrency: "USD",
								commission: 0.08,
								commissionCurrency: "USD",
								tradeValueId: "1"))

			var transactions: [Transaction] = []

			transactions.append(Transaction(id: 0,
											dateTime: formatter.date(from: "2019-11-25T01:00:00") ?? Date(),
											amount: 0.027,
											currency: "LTC",
											transactionValueId: "9",
											transactionStatus: "Complete",
											transactionType: "Deposit",
											commission: 0.002))

			transactions.append(Transaction(id: 0,
											dateTime: formatter.date(from: "2019-11-24T20:30:00") ?? Date(),
											amount: 0.001,
											currency: "BTC",
											transactionValueId: "5",
											transactionStatus: "Complete",
											transactionType: "Deposit",
											commission: 0.0001))

			transactions.append(Transaction(id: 2,
											dateTime: formatter.date(from: "2019-11-24T19:30:00") ?? Date(),
											amount: 10.96,
											currency: "USD",
											transactionValueId: "3",
											transactionStatus: "Complete",
											transactionType: "Withdraw",
											commission: 0.00035))

			transactions.append(Transaction(id: 3,
											dateTime: formatter.date(from: "2019-11-24T19:29:00") ?? Date(),
											amount: 10.96, currency: "USD",
											transactionValueId: "2",
											transactionStatus: "Failed",
											transactionType: "Withdraw",
											commission: 0.00035))

			transactions.append(Transaction(id: 4,
											dateTime: formatter.date(from: "2019-11-24T18:00:00") ?? Date(),
											amount: 0.001,
											currency: "BTC",
											transactionValueId: "0",
											transactionStatus: "Failed",
											transactionType: "Deposit",
											commission: 0.00035))

			let assets = self.api.getAssetsFromTradesAndTransactions(trades: &trades, transactions: &transactions, start: Date(timeIntervalSince1970: 0),
			end: Date(timeIntervalSinceNow: 0))

			result.forEach { (key, value) in
				let digits = String(result[key] ?? 0).count - String(Int(result[key] ?? 0)).count
				XCTAssertEqual(assets.0[key] ?? 0.0, value, accuracy: pow(0.1, Double(digits)))
			}

		}

	func testgetAssetsInPeriod() {

			var trades: [Trade] = []

			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

//			mutableListOf(Rate(BigDecimal( "8098"),1583798400), Rate(BigDecimal( "7627"),1583884800),
//			Rate(BigDecimal( "7268"),1583971200), Rate(BigDecimal( "7311"),1584057600), Rate(BigDecimal( "6903"),1583798400),
//			Rate(BigDecimal( "7109"),1583884800))

			let result = ["EOS": 1.495 ,
						  "BTC": 0.000377,
						  "LTC": -0.07535,
						  "USD": -11.44935,
						  "EUR": 0.1974001]

			trades.append(Trade(id: 0,
								dateTime: formatter.date(from: "2020-03-16T00:00:00") ?? Date(),
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
								dateTime: formatter.date(from: "2020-03-15T23:59:59") ?? Date(),
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
								dateTime: formatter.date(from: "2020-03-13T02:59:59") ?? Date(),
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
								dateTime: formatter.date(from: "2020-03-12T21:00:00") ?? Date(),
								instrument: "ltc-eur",
								tradeType: "Sell",
								tradedQuantity: 0.001,
								tradedQuantityCurrency: "btc",
								tradedPrice: 47.6,
								tradedPriceCurrency: "eur",
								commission: 0.01,
								commissionCurrency: "eur",
								tradeValueId: "11"))
			trades.append(Trade(id: 4,
								dateTime: formatter.date(from: "2020-03-12T00:00:00") ?? Date(),
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
								dateTime: formatter.date(from: "2020-03-09T23:12:45") ?? Date(),
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
								dateTime: formatter.date(from: "2020-03-09T23:00:00") ?? Date(),
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
											dateTime: formatter.date(from: "2020-03-17T01:00:00") ?? Date(),
											amount: 0.027,
											currency: "ltc",
											transactionValueId: "16",
											transactionStatus: "Complete",
											transactionType: "Deposit",
											commission: 0.002))

			transactions.append(Transaction(id: 1,
											dateTime: formatter.date(from: "2020-03-16T20:30:00") ?? Date(),
											amount: 0.001,
											currency: "btc",
											transactionValueId: "15",
											transactionStatus: "Complete",
											transactionType: "Deposit",
											commission: 0.0001))

			transactions.append(Transaction(id: 2,
											dateTime: formatter.date(from: "2020-03-12T19:30:00") ?? Date(),
											amount: 10.96,
											currency: "usd",
											transactionValueId: "0",
											transactionStatus: "Complete",
											transactionType: "Withdraw",
											commission: 0.001))

			transactions.append(Transaction(id: 3,
											dateTime: formatter.date(from: "2020-03-12T18:30:00") ?? Date(),
											amount: 0.0003,
											currency: "btc",
											transactionValueId: "9",
											transactionStatus: "Complete",
											transactionType: "Withdraw",
											commission: 0.0001))

			transactions.append(Transaction(id: 4,
											dateTime: formatter.date(from: "2020-03-12T18:29:00") ?? Date(),
											amount: 0.0002,
											currency: "BTC",
											transactionValueId: "8",
											transactionStatus: "Failed",
											transactionType: "Withdraw",
											commission: 0.0001))

			transactions.append(Transaction(id: 5,
											dateTime: formatter.date(from: "2020-03-10T18:30:00") ?? Date(),
											amount: 0.002,
											currency: "btc",
											transactionValueId: "6",
											transactionStatus: "Complete",
											transactionType: "Deposit",
											commission: 0.00035))

			transactions.append(Transaction(id: 6,
											dateTime: formatter.date(from: "2020-01-24T19:29:00") ?? Date(),
											amount: 10.96,
											currency: "BTC",
											transactionValueId: "3",
											transactionStatus: "Failed",
											transactionType: "Withdraw",
											commission: 0.00035))

			transactions.append(Transaction(id: 7,
											dateTime: formatter.date(from: "2020-01-24T19:28:00") ?? Date(),
											amount: 10.96,
											currency: "BTC",
											transactionValueId: "2",
											transactionStatus: "Complete",
											transactionType: "Deposit",
											commission: 0.00035))

			transactions.append(Transaction(id: 8,
											dateTime: formatter.date(from: "2020-01-24T18:01:00") ?? Date(),
											amount: 0.001,
											currency: "BTC",
											transactionValueId: "1",
											transactionStatus: "Complete",
											transactionType: "Deposit",
											commission: 0.0001))

			transactions.append(Transaction(id: 9,
											dateTime: formatter.date(from: "2020-01-24T18:00:00") ?? Date(),
											amount: 0.001,
											currency: "btc",
											transactionValueId: "0",
											transactionStatus: "Failed",
											transactionType: "Deposit",
											commission: 0.00035))

//		let assets = self.api.getAssetsForActiveCost(trades: &trades, transactions: &transactions, start: Date(timeIntervalSince1970: 1583798400),
//		end: Date(timeIntervalSince1970: 1584230400))

//		print(assets.0)
//		result.forEach { (key, value) in
//			let digits = String(result[key] ?? 0).count - String(Int(result[key] ?? 0)).count
//			XCTAssertEqual(assets.0[key] ?? 0.0, value, accuracy: pow(0.1, Double(digits)))
//		}

	}

}
