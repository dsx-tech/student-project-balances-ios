//
//  PieChartVCCharts.swift
//  graphs
//
//  Created by Danila Ferents on 08.12.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit
import Charts

class LineChartVCCharts: UIViewController, ChartViewDelegate {
	//Variables
	@IBOutlet weak var chartView: LineChartView!
	@IBOutlet weak var chartTitle: UILabel!
	var trades: [Trade]!
	var transactions: [Transaction]!


//	enum year: Int {
//		case December = 31
//		case Januar = 31
//		case
//	}

	override func viewDidLoad() {
		super.viewDidLoad()
		chartTitle.text = "Assets"
		chartView.delegate = self

		chartView.chartDescription?.enabled = false
		chartView.dragEnabled = true
		chartView.setScaleEnabled(true)
		chartView.pinchZoomEnabled = true

		chartView.xAxis.gridLineDashLengths = [10, 10]
		chartView.xAxis.gridLineDashPhase = 0

		let leftAxis = chartView.leftAxis
		leftAxis.axisMaximum = 55
		leftAxis.axisMinimum = 0
		leftAxis.gridLineDashLengths = [5, 5]
		leftAxis.drawLimitLinesBehindDataEnabled = true
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .topInside
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
		xAxis.labelTextColor = .black
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = true
        xAxis.centerAxisLabelsEnabled = true
		xAxis.valueFormatter = DateValueFormatter()
		chartView.rightAxis.enabled = false

		let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
								   font: .systemFont(ofSize: 12),
								   textColor: .white,
								   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
		marker.chartView = chartView
		marker.minimumSize = CGSize(width: 80, height: 40)
		chartView.marker = marker

		chartView.legend.form = .line

//		chartView.animate(xAxisDuration: 3.0)

		let tradesApi = TradeApi()
		tradesApi.getAllTrades(url: "http://3.248.170.197:9999/bcv/trades") { (trades) in
			if let trades = trades {
				self.trades = trades
				tradesApi.getAllTransactions(url: "http://3.248.170.197:9999/bcv/transactions") { (transactions) in
					if let transactions = transactions {
						self.transactions = transactions

						let formatter = DateFormatter()
						//			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
						formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

						var end1 = formatter.date(from: "2019-12-31T23:59:59")
						var start1 = formatter.date(from: "2019-01-01T00:00:01")

//						let (assets1, _) = self.getAssetsFromTradesAndTransactions(trades: &self.trades, transactions: &self.transactions, start: Date(timeIntervalSince1970: 0), end: end!)

//						print(assets1)
						var end = formatter.date(from: "2019-12-09T23:59:59")
						var start = formatter.date(from: "2014-01-01T00:00:01")

						let numberOfMinths = Calendar.current.dateComponents([.month], from: start!, to: end!).month!
//						print(numberOfMinths)
						var dateComponents =  DateComponents()
						var assetsMonthly: [String: ([Double],[Double])] = [:]

						for i in 0..<numberOfMinths {
							dateComponents.month = i
							let newdate = Calendar.current.date(byAdding: dateComponents, to: start!)!
							let (assets, _) = self.getAssetsFromTradesAndTransactions(trades: &self.trades, transactions: &self.transactions, start: start!, end: newdate)
							for (key, value) in assets {
								if let _ = assetsMonthly[key] {
									if newdate < start1! || newdate > end1! {
										continue
									}
									assetsMonthly[key]!.0.append(value)
									assetsMonthly[key]!.1.append(newdate.timeIntervalSince1970)
								} else {
									if newdate < start1! || newdate > end1! {
										continue
									}
									assetsMonthly[key] = ([value],[newdate.timeIntervalSince1970])
								}
							}
						}
						self.setDataCount(data: assetsMonthly)

//						self.getAssetsDateAndAmount(trades: trades, transactions: transactions, timeInterval: 30, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSinceNow: 0), allassets: newassets)
					}
				}
			}
		}
	}


	func setDataCount(data: [String: ([Double],[Double])]) {

		var datasets:[LineChartDataSet] = []

//		for (asset, values) in data {
			let values = (0..<data["USD"]!.0.count).map { (i) -> ChartDataEntry in
				return ChartDataEntry(x: data["USD"]!.1[i], y: data["USD"]!.0[i])
			}

			let set1 = LineChartDataSet(entries: values, label: "USD")
			set1.drawIconsEnabled = false

			set1.lineDashLengths = [5, 2.5]
			set1.highlightLineDashLengths = [5, 2.5]
			set1.setColor(.black)
			set1.setCircleColor(.black)
			set1.lineWidth = 1
			set1.circleRadius = 3
			set1.drawCircleHoleEnabled = false
			set1.valueFont = .systemFont(ofSize: 9)
			set1.formLineDashLengths = [5, 2.5]
			set1.formLineWidth = 1
			set1.formSize = 15

			let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
								  ChartColorTemplates.colorFromString("#ffff0000").cgColor]
			let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

			set1.fillAlpha = 1
			set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
			set1.drawFilledEnabled = true
			datasets.append(set1)
//		}
		let data = LineChartData(dataSets: datasets)

		chartView.data = data
	}


//	func getAssetsDateAndAmount(trades: [Trade], transactions: [Transaction], timeInterval: TimeInterval, start: Date, end: Date, allassets: [String]) {
//		var assets: [String: Double] = [:]
//		var assetsValueAndData: [TimeInterval: [String: Double]] = [:]
//
//		var tradeindex = 0, transactionindex = 0
//
//		for _ in 0..<trades.count + transactions.count {
//
//			if tradeindex < trades.count && (trades[tradeindex].dateTime < start || trades[tradeindex].dateTime > end) {
//				tradeindex += 1
//				continue
//			}
//
//			if transactionindex < transactions.count && (transactions[transactionindex].dateTime < start || transactions[transactionindex].dateTime > end) {
//				transactionindex+=1
//				continue
//			}
//
//			if transactionindex < transactions.count && tradeindex < trades.count {
//				if transactions[transactionindex].dateTime <= trades[tradeindex].dateTime {
//
//					processTransactionTime(transaction: transactions[transactionindex], assets: &assets, assetsWithTime:  &assetsValueAndData)
//					transactionindex += 1
//				} else {
//					processTradeTime(trade: trades[tradeindex], assets: &assets, assetsWithTime: &assetsValueAndData)
//					tradeindex += 1
//				}
//			} else if transactionindex >= transactions.count {
//				processTradeTime(trade: trades[tradeindex], assets: &assets, assetsWithTime: &assetsValueAndData)
//				tradeindex += 1
//			} else if tradeindex >= trades.count {
//				processTransactionTime(transaction: transactions[transactionindex], assets: &assets, assetsWithTime:  &assetsValueAndData)
//				transactionindex += 1
//			}
//		}
//
//
//
//
////		var assetsMonthly: [String: [Double]] = [:]
////		var monthcounter: TimeInterval = 1
////		let sortedassetswithdata = assetsValueAndData.sorted { $0.key < $1.key}
////
////		for asset in allassets {
//// 			assetsMonthly[asset] = []
////		}
////
////		if sortedassetswithdata[0].key > start.timeIntervalSince1970 && sortedassetswithdata[0].key < (start.timeIntervalSince1970 + 2592000) {
////			for (asset, value) in sortedassetswithdata[0].value {
////				if let optional = assetsMonthly[asset] {
////					assetsMonthly[asset]!.append(value)
////				} else {
////					assetsMonthly[asset] = [value]
////				}
////			}
////		}
//////		} else {
//////			for (asset, _) in assetsMonthly {
//////					assetsMonthly[asset]!.append(0)
//////			}
//////		}
////
////
////		for i in 1..<sortedassetswithdata.count {
////			if sortedassetswithdata[i].key < (monthcounter * 2592000) {
////				continue
////			} else if sortedassetswithdata[i - 1].key > ((monthcounter - 1) * 2592000) {
////				monthcounter += 1
////				for (asset, value) in sortedassetswithdata[i - 1].value {
////					if let optional = assetsMonthly[asset] {
////						assetsMonthly[asset]!.append(value)
////					} else {
////						assetsMonthly[asset] = [value]
////					}
////				}
////			} else {
////				for (asset, _) in assetsMonthly {
////						assetsMonthly[asset]!.append(0)
////				}
////			}
////		}
//
//	}
//
//	func processTradeTime(trade: Trade, assets: inout [String: Double], assetsWithTime: inout [TimeInterval: [String: Double]]){
//
//
//		var deductibleQuantity: Double = 0
//		var addedQuantity: Double = 0
//		var deductibleCurrency: String = ""
//		var addedCurrency: String = ""
//
//		if trade.tradeType == "Sell" {
//			deductibleCurrency = trade.tradedQuantityCurrency
//			deductibleQuantity = trade.tradedQuantity
//			addedCurrency = trade.tradedPriceCurrency
//			addedQuantity = trade.tradedPrice * trade.tradedQuantity
//		} else if trade.tradeType == "Buy" {
//			deductibleCurrency = trade.tradedPriceCurrency
//			deductibleQuantity = trade.tradedPrice * trade.tradedQuantity
//			addedCurrency = trade.tradedQuantityCurrency
//			addedQuantity = trade.tradedQuantity
//		}
//
//		if let currentassetQuantity = assets[deductibleCurrency] {
//			if currentassetQuantity < deductibleQuantity {
//				assets[deductibleCurrency]! -= deductibleQuantity
//			} else {
//				assets[deductibleCurrency] = -deductibleQuantity
//			}
//
//			if let _ = assets[addedCurrency] {
//				assets[addedCurrency]! += addedQuantity
//			} else {
//				assets[addedCurrency] = addedQuantity
//			}
//		}
//
//		if let _ = assets[addedCurrency] {
//			assets[addedCurrency]! += addedQuantity
//		} else {
//			assets[addedCurrency] = addedQuantity
//		}
//
//		assetsWithTime[trade.dateTime.timeIntervalSince1970] = assets
//	}
//
//	func processTransactionTime(transaction: Transaction, assets: inout [String: Double], assetsWithTime: inout [TimeInterval: [String: Double]]) {
//
//		if transaction.transactionType == "Withdraw" {
//			if let currentassetQuantity = assets[transaction.currency] {
//				if currentassetQuantity < transaction.amount {
//				}
//				assets[transaction.currency]! -= transaction.amount
//			} else {
//				assets[transaction.currency] = -transaction.amount
//			}
//		} else if transaction.transactionType == "Deposit" {
//			if let _ = assets[transaction.currency] {
//				assets[transaction.currency]! += transaction.amount
//			} else {
//				assets[transaction.currency] = transaction.amount
//			}
//		}
//		assetsWithTime[transaction.dateTime.timeIntervalSince1970] = assets
//	}

	func getAssetsFromTradesAndTransactions(trades: inout [Trade], transactions: inout [Transaction], start: Date, end: Date) -> ([String: Double], [(String, String, String)]) {
		var strangeIds: [(String,String, String)] = []
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
