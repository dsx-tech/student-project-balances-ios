//
//  StackedBarChartVC.swift
//  graphs
//
//  Created by Danila Ferents on 10.12.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit
import Charts

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

class StackedBarChartVC: UIViewController, ChartViewDelegate {

	//Variables
	@IBOutlet weak var titleLbl: UILabel!
	@IBOutlet weak var optionBtn: UIButton!
	@IBOutlet weak var chartView: BarChartView!
	var trades: [Trade]!
	var transactions: [Transaction]!

	lazy var formatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = 1
		formatter.negativeSuffix = " $"
		formatter.positiveSuffix = " $"

		return formatter
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		chartView.delegate = self

		chartView.chartDescription?.enabled = false

		chartView.maxVisibleCount = 40
		chartView.drawBarShadowEnabled = false
		chartView.drawValueAboveBarEnabled = false
		chartView.highlightFullBarEnabled = false

		let leftAxis = chartView.leftAxis
		leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
		leftAxis.axisMinimum = 0

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .topInside
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
		xAxis.labelTextColor = .black
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = true
        xAxis.centerAxisLabelsEnabled = true
		xAxis.valueFormatter = DateValueFormatterNew()
		chartView.rightAxis.enabled = false
		chartView.rightAxis.enabled = false

		let l = chartView.legend
		l.horizontalAlignment = .right
		l.verticalAlignment = .bottom
		l.orientation = .horizontal
		l.drawInside = false
		l.form = .square
		l.formToTextSpace = 4
		l.xEntrySpace = 6
		//        chartView.legend = l

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

						let optend = formatter.date(from: "2020-01-31T23:59:59")
						let optstart = formatter.date(from: "2014-11-01T00:59:59")

						guard var start = optstart, var end = optend else { return }

						let (assets1, _) = self.getAssetsFromTradesAndTransactions(trades: &self.trades,
																				   transactions: &self.transactions,
																				   start: Date(timeIntervalSince1970: 0),
																				   end: end)

						print(assets1)
						end = formatter.date(from: "2019-12-09T23:59:59") ?? Date()
						start = formatter.date(from: "2019-01-01T00:00:01") ?? Date()
						guard let numberOfMinths = Calendar.current.dateComponents([.month], from: start, to: end).month else { return }
						//						print(numberOfMinths)
						var dateComponents = DateComponents()
						var assetsMonthly: [(Date, [Double])] = []
						var labels: [String] = []

						for i in 0..<numberOfMinths {
							dateComponents.month = i
							guard let newdate = Calendar.current.date(byAdding: dateComponents, to: start) else { return }
							let (assets, _) = self.getAssetsFromTradesAndTransactions(trades: &self.trades, transactions: &self.transactions, start: start, end: newdate)
							let sortedassets = assets.sorted { $0.key < $1.key }
							var assetsNames: [String] = []
							var assetsValues: [Double] = []
							for (key, value) in sortedassets {
								assetsNames.append(key)
								if let currency = currencies1[key] {
									assetsValues.append(value * currency)
								}
							}
							if i == (numberOfMinths - 1) {
								labels = assetsNames
							}
							assetsMonthly.append((newdate, assetsValues))
						}
						self.setData(data: assetsMonthly, labels: labels)
//						self.setChartData(count: 7, range: 9)
					}
				}
			}
		}
	}

	func setData(data: [(Date, [Double])], labels: [String]) {

		let yVals = (0..<data.count).map { (i) -> BarChartDataEntry in

			var values = data[i].1
			for _ in data[i].1.count..<labels.count {
				values.append(0)
			}
			return BarChartDataEntry(x: Double(i), yValues: values)
			   }

        let set = BarChartDataSet(entries: yVals, label: "")
        set.drawIconsEnabled = false
		let colors = (0..<labels.count).map { (_) -> UIColor in
            return UIColor(red: .random(),
			green: .random(),
			blue: .random(),
			alpha: 1.0)
        }
		set.colors = colors
		set.stackLabels = labels

        let data = BarChartData(dataSet: set)
        data.setValueFont(.systemFont(ofSize: 4, weight: .light))
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        data.setValueTextColor(.clear)

        chartView.fitBars = true
        chartView.data = data
		chartView.animate(xAxisDuration: 1.0)
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

			if tradeindex < trades.count && (trades[tradeindex].dateTime < start || trades[tradeindex].dateTime > end) {
				tradeindex += 1
				continue
			}

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
		//		print(assets, trade.id)
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
