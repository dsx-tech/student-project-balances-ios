//
//  ViewController.swift
//  graphs
//
//  Created by Danila Ferents on 25.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	var trades: [Trade]!
	var transactions: [Transaction]!

	override func viewDidLoad() {
		super.viewDidLoad()
		let tradesApi = TradeApi()
		tradesApi.getAllTrades(url: "http://3.248.170.197:9999/bcv/trades") { (trades) in
			if let trades = trades {
				self.trades = trades
				tradesApi.getAllTransactions(url: "http://3.248.170.197:9999/bcv/transactions") { (transactions) in
					if let transactions = transactions {
						self.transactions = transactions
						let (assets, strangeIds) = self.getAssetsFromTradesAndTransactions(trades: &self.trades, transactions: &self.transactions)
						print(assets, strangeIds)
					}
				}
			}
 		}
	}

	func getAssetsFromTradesAndTransactions(trades: inout [Trade], transactions: inout [Transaction]) -> ([String: Double], [(String, String, String)]) {
		var strangeIds: [(String, String, String)] = []
		var assets: [String: Double] = [:]

		trades.sort { (firsttrade, secondtrade) -> Bool in
			return firsttrade.dateTime < secondtrade.dateTime
		}

		transactions.sort { (firsttransaction, secondtransaction) -> Bool in
			return firsttransaction.dateTime < secondtransaction.dateTime
		}

		var tradeindex = 0, transactionindex = 0

		for _ in 0..<trades.count + transactions.count {

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
	}

}
