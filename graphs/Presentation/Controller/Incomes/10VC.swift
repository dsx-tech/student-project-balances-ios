//
//  10VC.swift
//  graphs
//
//  Created by Danila Ferents on 25.02.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import Charts

class VC10: UIViewController, ChartViewDelegate {

	//Outlets
	@IBOutlet weak var chartView: HorizontalBarChartView!

	//Variables
	var transactions: [Transaction]!
	let tradesApi = TradeApi()
	let transactionsApi = TransactionApi()

    lazy var customFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = 1
		formatter.negativeSuffix = " $"
		formatter.positiveSuffix = " $"
		formatter.negativePrefix = ""
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

		setUpChart()

		tradesApi.getAllTransactions(completion: { (transactions) in
			if let transactions = transactions {
				self.transactions = transactions
			}

			let formatter = DateFormatter()

			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

			let end = formatter.date(from: "2015-01-31T23:59:59")
			let start = formatter.date(from: "2014-01-01T00:59:59")
			let balances = self.transactionsApi.getDatafromTransactions(transactions: &self.transactions, interval: .month, start: start ?? Date(), end: end ?? Date())
//			xAxis.labelCount = balances.count
//			xAxis.valueFormatter = DateValueFormatter10(start: start ?? Date())
			self.setChartData(dateDepositWithdraw: balances)
		})
    }
}

// - MARK: Reload Data
extension VC10 {
		func setChartData(dateDepositWithdraw: [Date: (Double, Double)]) {
			var yVals: [BarChartDataEntry] = []
	//		var yVals = [BarChartDataEntry(x: 5, yValues: [-10, 10]),
	//							BarChartDataEntry(x: 15, yValues: [-12, 13]),
	//							BarChartDataEntry(x: 25, yValues: [-15, 0]),
	//							BarChartDataEntry(x: 35, yValues: [-17, 17]),
	//			   ]
			var i = 0.0
			for (_, value) in dateDepositWithdraw {
				yVals.append(BarChartDataEntry(x: i, yValues: [-value.0, value.1]))
				i += 10
			}
			yVals.sort { (entry1, entry2) -> Bool in
				return entry1.x < entry2.x
			}
			print(yVals)
			let set = BarChartDataSet(entries: yVals, label: "Deposit/Withdraw")
			set.drawIconsEnabled = false
			set.valueFormatter = DefaultValueFormatter(formatter: customFormatter)
			set.valueFont = .systemFont(ofSize: 7)
			set.axisDependency = .right
			set.colors = [UIColor(red: 67 / 255, green: 67 / 255, blue: 72 / 255, alpha: 1),
						  UIColor(red: 124 / 255, green: 181 / 255, blue: 236 / 255, alpha: 1)
			]
			set.stackLabels = ["Deposit", "Withdraw"]

			let data = BarChartData(dataSet: set)
			data.barWidth = 8.5

			chartView.data = data
	//		guard let maxdeposit = dateDepositWithdraw.max(by: { (first, second) -> Bool in
	//			return first.value.0 > second.value.0 }) else {return}
	//		chartView.rightAxis.axisMaximum = maxdeposit.value.0
	//
	//		guard let maxwithdraw = dateDepositWithdraw.max(by: { (first, second) -> Bool in
	//			return first.value.1 > second.value.1 }) else {return}
	//		chartView.rightAxis.axisMinimum = maxwithdraw.value.1
			chartView.setNeedsDisplay()
		}
}

// - MARK: Set Up functions

extension VC10 {
	func setUpChart() {
			chartView.delegate = self

			chartView.chartDescription?.enabled = false

			chartView.drawBarShadowEnabled = false
			chartView.drawValueAboveBarEnabled = true

			chartView.leftAxis.enabled = false

			let rightAxis = chartView.rightAxis
			rightAxis.drawZeroLineEnabled = true
			rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: customFormatter)
			rightAxis.labelFont = .systemFont(ofSize: 9)

			let xAxis = chartView.xAxis
			xAxis.labelPosition = .bothSided
			xAxis.drawAxisLineEnabled = false
			xAxis.centerAxisLabelsEnabled = true
	//		xAxis.valueFormatter = self
			xAxis.labelFont = .systemFont(ofSize: 9)

			let l = chartView.legend
			l.horizontalAlignment = .right
			l.verticalAlignment = .bottom
			l.orientation = .horizontal
			l.formSize = 8
			l.formToTextSpace = 8
			l.xEntrySpace = 6
	}
}

// - MARK: formatter

extension VC10: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(format: "%03.0f", value)
    }
}
