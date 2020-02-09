//
//  PieChartVC.swift
//  graphs
//
//  Created by Danila Ferents on 25.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit
import AAInfographics

extension UIColor {
	  func toHexString() -> String {
		  var r:CGFloat = 0
		  var g:CGFloat = 0
		  var b:CGFloat = 0
		  var a:CGFloat = 0

		  getRed(&r, green: &g, blue: &b, alpha: &a)

		  let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

		  return String(format:"#%06x", rgb)
	  }
  }

class PieChartVC: UIViewController {

	//Variables
	var chartView: AAChartView! //View in which Chart is drown

	var chartModel: AAChartModel! //Model
	var assetsApi = AssetsApi() //struct to handle Network connection

	var trades: [Trade]! //trades from backend
	var transactions: [Transaction]! //transactions from backend

    override func viewDidLoad() {
        super.viewDidLoad()

		setUpChartView() //set size for view
		view.addSubview(chartView!)

		//get all trades and transactions
		let tradesApi = TradeApi()
		tradesApi.getAllTrades(url: "http://3.248.170.197:9999/bcv/trades") { (trades) in
			if let trades = trades {
				self.trades = trades
				tradesApi.getAllTransactions(url: "http://3.248.170.197:9999/bcv/transactions") { (transactions) in
					if let transactions = transactions {
						self.transactions = transactions
						let (assets1, strangeIds) = self.getAssetsFromTradesAndTransactions(trades: &self.trades, transactions: &self.transactions, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSinceNow: 0))
						print(assets1)
						var newassets: [Any] = []
						for (key, value) in assets1 {
//							if value < 0 {
//								continue
//							}
							newassets.append([key, value * currencies1[key]!])
						}
//						var assets = AssetsTimeData(assets: )
//						assets.convertToStringAny()
						self.chartModel = self.configurePieChartModel(data: newassets)
						print(newassets)
						self.chartView!.aa_drawChartWithChartModel(self.chartModel)
				}
			}
 		}
		self.chartModel = self.configurePieChartModel(data: [])
		self.chartView!.aa_drawChartWithChartModel(self.chartModel)
		}}

	private func setUpChartView() {
		chartView = AAChartView()

		let chartWidth = view.frame.size.width
		let chartHeight = view.frame.size.height
		chartView!.frame = CGRect(x: 0, y: 0, width: chartWidth, height: chartHeight)
		chartView!.contentHeight = view.frame.size.height - 80
		chartView!.scrollEnabled = false
	}

	private func configurePieChartModel(data: [Any]) -> AAChartModel {
			let colors = (0..<data.count).map { (i) -> String in
            let color =  UIColor(red:   .random(),
			green: .random(),
			blue:  .random(),
				alpha: 1.0)

				return color.toHexString()
        }

		return AAChartModel()
			.colorsTheme(colors)
			.chartType(.pie)
			.backgroundColor(AAColor.white)
			.title("Portfolio Assets")
			.dataLabelsEnabled(true)
//			.backgroundColor("#4169E1")
			.series([
				AASeriesElement()
				.name("$")
				.innerSize("10%")
//				.allowPointSelect(true)
//				.data([
//					["$", 5],
//					["€", 10],
//					["฿", 15],
//					]
//				)
				.data(data)
			])

	}

	/**counting assets between two dates from trades and transactions
	 - Author: Danila Ferents
	- Parameters:
		- trades: All trades
		- transactions: All transactions
		- start: Start date of interval
		- end: End date of interval
	- Returns: Dictionary of value and count, array of strange transactions and trades
	*/
	func getAssetsFromTradesAndTransactions(trades: inout [Trade], transactions: inout [Transaction], start: Date, end: Date) -> ([String: Double], [(String, String, String)]) {

		///Array of strange Ids
		var strangeIds: [(String,String, String)] = []
		///Dictionary of all assets
		var assets: [String: Double] = [:]

		//sorting trades and transactions
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
		//processing all transactions, which are in interval between start and end
		for _ in 0..<trades.count + transactions.count {

			if tradeindex < trades.count && (trades[tradeindex].dateTime < start || trades[tradeindex].dateTime > end) {
				tradeindex += 1
				continue
			}

			if transactionindex < transactions.count && (transactions[transactionindex].dateTime < start || transactions[transactionindex].dateTime > end) {
				transactionindex+=1
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

	/**
	Increase and Decrease assets, which have been traded
	- Author: Danila Ferents
	- Parameters:
		- trade: Processing trade
		- assets: Dictionary of assets(by reference)
		- strangeIds: Array of strange ids(by reference)
	*/
	func processTrade(trade: Trade, assets: inout [String: Double],strangeIds: inout [(String, String, String)]) {


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
				strangeIds.append(("Trade", trade.tradeValueId , deductibleCurrency)) }
			assets[deductibleCurrency]! -= deductibleQuantity
		} else {
			assets[deductibleCurrency] = -deductibleQuantity
			strangeIds.append(("Trade", trade.tradeValueId , deductibleCurrency))
		}

		if let _ = assets[addedCurrency] {
			assets[addedCurrency]! += addedQuantity
		} else {
			assets[addedCurrency] = addedQuantity
		}
		if let _  = assets[trade.commissionCurrency] {
			assets[trade.commissionCurrency]! -= trade.commission
		} else {
			assets[trade.commissionCurrency] = -trade.commission
		}
		//		print(assets, trade.id)
	}

	/**
	Increase  asset, which is in transaction
	- Author: Danila Ferents
	- Parameters:
		- transaction: Processing transaction
		- assets: Dictionary of assets(by reference)
		- strangeIds: Array of strange ids(by reference)
	*/
	func processTransaction(transaction: Transaction, assets: inout [String: Double],strangeIds: inout [(String, String, String)]) {

		if transaction.transactionType == "Withdraw" {
			if let currentassetQuantity = assets[transaction.currency] {
				if currentassetQuantity < transaction.amount {
					strangeIds.append(("Transaction", transaction.transactionValueId, transaction.currency))
				}
				assets[transaction.currency]! -= transaction.amount
			} else {
				assets[transaction.currency] = -transaction.amount
				strangeIds.append(("Transaction", transaction.transactionValueId, transaction.currency))
			}
		} else if transaction.transactionType == "Deposit" {
			if let _ = assets[transaction.currency] {
				assets[transaction.currency]! += transaction.amount
			} else {
				assets[transaction.currency] = transaction.amount
			}
		}
		assets[transaction.currency]! -= transaction.commission
		//		print(assets, transaction.id)
	}
}
