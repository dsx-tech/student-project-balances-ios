//
//  CorrelationGraphVC.swift
//  graphs
//
//  Created by Danila Ferents on 19.02.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import Charts

class CorrelationGraphVC: UIViewController, ChartViewDelegate {

	@IBOutlet weak var chartView: LineChartView!
	var vc: CorrelationVC!
	var firstInstrument: String!
	var secondInstrument: [String]!
	var firstQuotes: [QuotePeriod]!
	var secondQuotes: [QuotePeriod]!
	let quotesApi = TradeApi()

	var correlations: [String: ([Double], [Double])] = [:]

	override func viewDidLoad() {
		super.viewDidLoad()

		setUpGraph()

		let formatter = DateFormatter()

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		guard let start = formatter.date(from: "2018-01-01T00:00:01") else { return }

		secondInstrument.forEach { (instrument) in
			callculatecorrelation(firstinstrument: self.firstInstrument, secondinstrument: instrument, startDate: start, duration: .sixmonths)
		}
	}
}

// - MARK: Correlation

extension CorrelationGraphVC {
	/**
	callculationg correlation from start date for duration between two instruments
	- Author: Danila Ferents
	- Parameters:
	- firstinstrument: first instrument to callculate
	- secondinstrument: second instrument to callculate
	- startDate: Start date of interval
	- duration: quotesDuration enum
	- Returns: corellation value
	*/
	func callculatecorrelation(firstinstrument: String, secondinstrument: String, startDate: Date, duration: DurationQuotes) {

		//number of months to count corellation, which we take from duration parameter
		var dateComponents = DateComponents()
		switch duration {

		case .month:
			dateComponents.month = 1
		case .threemonths:
			dateComponents.month = 3
		case .sixmonths:
			dateComponents.month = 6
		case .year:
			dateComponents.month = 12
		}

		guard let enddate = Calendar.current.date(byAdding: dateComponents, to: startDate) else {
			print("Error in converting end date.")
			return
		}
		//get quotes for first instrument
		quotesApi.getQuotesinPeriod(instruments: [firstinstrument, secondinstrument], startTime: startDate, endTime: enddate) { (quotes)  in

			guard let quotesArray = quotes,
				let firstQuotes = quotesArray[firstinstrument],
				let secondQuotes = quotesArray[secondinstrument] else {
					print("Error in getting quotes for  instrument")
					return
			}

			//				let correlation = self.correlationQuotes(firstquotes: firstQuotes, secondquotes: secondQuotes)

			let numberOfMinths = dateComponents.month ?? 0
			//						print(numberOfMinths)

			for i in 0..<numberOfMinths {
				dateComponents.month = i
				let newdate = Calendar.current.date(byAdding: dateComponents, to: startDate) ?? Date()
				let correl = CorrelationApi.sharedManager.correlationQuotes(firstquotes: firstQuotes.filter({ (quote) -> Bool in
					return quote.timestamp <= Int64(newdate.timeIntervalSince1970)
				}), secondquotes: secondQuotes.filter({ (quote) -> Bool in
					return quote.timestamp <= Int64(newdate.timeIntervalSince1970)
				}))

				if self.correlations[secondinstrument] != nil {
					self.correlations[secondinstrument]?.0.append(newdate.timeIntervalSince1970)
					self.correlations[secondinstrument]?.1.append(correl)
				} else {
					self.correlations[secondinstrument] = ([newdate.timeIntervalSince1970], [correl])
				}

			}
			self.setDataCount(data: self.correlations)

		}
	}

}

// - MARK: Set Up functions

extension CorrelationGraphVC {
	func setUpGraph() {
		chartView.delegate = self

		chartView.chartDescription?.enabled = false
		chartView.dragEnabled = true
		chartView.setScaleEnabled(true)
		chartView.pinchZoomEnabled = true

		chartView.xAxis.gridLineDashLengths = [10, 10]
		chartView.xAxis.gridLineDashPhase = 0

		let leftAxis = chartView.leftAxis
		leftAxis.axisMaximum = 1
		leftAxis.axisMinimum = -1
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

extension CorrelationGraphVC {
	func setDataCount(data: [String: ([Double], [Double])]) {

		var datasets: [LineChartDataSet] = []

		data.forEach { (_, corellationWithDates) in
			let values = (0..<corellationWithDates.0.count).map { (i) -> ChartDataEntry in
				return ChartDataEntry(x: corellationWithDates.0[i], y: corellationWithDates.1[i])
			}

			let set1 = LineChartDataSet(entries: values, label: data.first?.key)
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
		}

		DispatchQueue.main.async {
			let data = LineChartData(dataSets: datasets)
			self.chartView.data = data
		}
	}
}
