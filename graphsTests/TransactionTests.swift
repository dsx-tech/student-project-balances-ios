//
//  TransactionTests.swift
//  
//
//  Created by Danila Ferents on 06.04.20.
//

import XCTest

class TransactionTests: XCTestCase {

	var api: TransactionApi!

	override func setUp() {
		super.setUp()
		api = TransactionApi()
	}

	override func tearDown() {
		super.tearDown()
		api = nil
	}

	func testgetDepositsWithdrows() {

		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

//		let result = [0,
//					  0,
//					  0,
//					  0,
//					  12.06315,
//					  6.62688,
//					  3536.7275,
//					  0,
//					  0,
//					  -0.252246
//		]

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

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

		let start = formatter.date(from: "2019-01-31T23:59:59Z")
		let end = formatter.date(from: "2019-12-20T00:59:59Z")

		let computedresult = api.getDatafromTransactions(transactions: &transactions, quotes: [:], interval: .month, start: start ?? Date(), end: end ?? Date())
		print(computedresult)
//		var i = 0
//		assets.forEach({ (_, value) in
//			let digits = Double(String(value).count - String(Int(value)).count)
//			XCTAssertEqual(value, result[i], accuracy: pow(0.1, digits))
//			i += 1
//		})
	}
}
