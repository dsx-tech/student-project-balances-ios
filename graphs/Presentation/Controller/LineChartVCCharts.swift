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
	let tradesApi = TradeApi()

	override func viewDidLoad() {
		super.viewDidLoad()

		setUpChartView()

		tradesApi.getAllTrades(completion: { (trades) in
			if let trades = trades {
				self.trades = trades
				self.tradesApi.getAllTransactions(completion: { (transactions) in
					if let transactions = transactions {
						self.transactions = transactions

						let formatter = DateFormatter()
						//			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
						formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

						let optend1 = formatter.date(from: "2019-12-31T23:59:59")
						let optstart1 = formatter.date(from: "2014-01-01T00:00:01")

//						let (assets1, _) = self.getAssetsFromTradesAndTransactions(trades: &self.trades,
						//transactions: &self.transactions,
						//start: Date(timeIntervalSince1970: 0),
						//end: end!)

//						print(assets1)
						let optend = formatter.date(from: "2019-12-09T23:59:59")
						let optstart = formatter.date(from: "2014-01-01T00:00:01")

						guard let start = optstart, let end = optend, let start1 = optstart1, let end1 = optend1 else { return }

						guard let numberOfMinths = Calendar.current.dateComponents([.month], from: start, to: end).month else { return }
//						print(numberOfMinths)
						var dateComponents = DateComponents()
						var assetsMonthly: [String: ([Double], [Double])] = [:]

						for i in 0..<numberOfMinths {
							dateComponents.month = i
							guard let newdate = Calendar.current.date(byAdding: dateComponents, to: start) else { return }
							let (assets, _) = ActiveCostAndPieApi.sharedManager.getAss (trades: &self.trades, transactions: &self.transactions, start: start, end: newdate)
							for (key, value) in assets {
								if assetsMonthly[key] !=  nil {
									if newdate < start1 || newdate > end1 {
										continue
									}
									assetsMonthly[key]?.0.append(value)
									assetsMonthly[key]?.1.append(newdate.timeIntervalSince1970)
								} else {
									if newdate < start1 || newdate > end1 {
										continue
									}
									assetsMonthly[key] = ([value], [newdate.timeIntervalSince1970])
								}
							}
						}
						DispatchQueue.main.async {
							self.setDataCount(data: assetsMonthly)
						}
//						self.getAssetsDateAndAmount(trades: trades, transactions: transactions,
						//timeInterval: 30,
						//start: Date(timeIntervalSince1970: 0),
							//end: Date(timeIntervalSinceNow: 0),
						//allassets: newassets)
					}
				})
			}
		})
	}

	func setDataCount(data: [String: ([Double], [Double])]) {

		var datasets: [LineChartDataSet] = []

//		for (asset, values) in data {
		guard let newdata = data["usd"] else { return }
			let values = (0..<newdata.0.count).map { (i) -> ChartDataEntry in
				let x = newdata.1[i]
				let y = newdata.0[i]
				let entry = ChartDataEntry(x: x, y: y)
				return entry
			}

			let set1 = LineChartDataSet(entries: values, label: "usd")
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
			guard let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil) else { return }

			set1.fillAlpha = 1
			set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
			set1.drawFilledEnabled = true
			datasets.append(set1)
//		}
		let data = LineChartData(dataSets: datasets)

		chartView.data = data
	}
}

// - MARK: ChartView

extension LineChartVCCharts {
	func setUpChartView() {
		chartTitle.text = "Assets"
		chartView.delegate = self

		chartView.chartDescription?.enabled = false
		chartView.dragEnabled = true
		chartView.setScaleEnabled(true)
		chartView.pinchZoomEnabled = true

		chartView.xAxis.gridLineDashLengths = [10, 10]
		chartView.xAxis.gridLineDashPhase = 0

		let leftAxis = chartView.leftAxis
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

		let marker = BalloonMarker(color: UIColor(white: 180 / 255, alpha: 1),
								   font: .systemFont(ofSize: 12),
								   textColor: .white,
								   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
		marker.chartView = chartView
		marker.minimumSize = CGSize(width: 80, height: 40)
		chartView.marker = marker

		chartView.legend.form = .line
	}
}
