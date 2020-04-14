//
//  ActiveCorrelationVC.swift
//  graphs
//
//  Created by Danila Ferents on 03.03.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import Charts

class ActiveCorrelationVC: UIViewController, ChartViewDelegate {

	//Outlets
	@IBOutlet weak var chartView: LineChartView!

	//Variables
	var firstQuotes: [Quote]!
	var secondQuotes: [Quote]!

	override func viewDidLoad() {
		super.viewDidLoad()

		chartView.delegate = self

		let formatter = DateFormatter()

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		guard let start = formatter.date(from: "2018-01-01T00:00:01") else { return }

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
		correlationBetween(firstinstrument: "eur-usd", secondinstrument: "btc-usd", startDate: start, duration: .sixmonths)
	}

	func setDataCount(data: [(String, [(Double, Double)])]) {

		var datasets: [LineChartDataSet] = []

		data.forEach { (instrument, normallisedquotesWithDates) in
			let values = (0..<normallisedquotesWithDates.count).map { (i) -> ChartDataEntry in
				return ChartDataEntry(x: normallisedquotesWithDates[i].0, y: normallisedquotesWithDates[i].1)
			}

			let set1 = LineChartDataSet(entries: values, label: instrument)
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
		let data = LineChartData(dataSets: datasets)

		chartView.data = data
	}

	/**
	visualise correlation from start date for duration between two instruments
	- Author: Danila Ferents
	- Parameters:
	- firstinstrument: first instrument to callculate
	- secondinstrument: second instrument to callculate
	- startDate: Start date of interval
	- duration: quotesDuration enum
	- Returns: corellation value
	*/
	func correlationBetween(firstinstrument: String, secondinstrument: String, startDate: Date, duration: DurationQuotes) {

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
		let quotesApi = TradeApi()
		quotesApi.getQuotesinPeriod(instrument: firstinstrument, startTime: startDate, endTime: enddate) { (firstinstrumentquotes) in
			quotesApi.getQuotesinPeriod(instrument: secondinstrument, startTime: startDate, endTime: enddate) { (secondinstrumentquotes) in
				guard let firstQuotes = firstinstrumentquotes, let secondQuotes = secondinstrumentquotes else {
					print("Error in getting quotes for  instrument")
					return
				}

				let (newfirstquotes, newsecondquotes) = self.correlationQuotes(firstquotes: firstQuotes, secondquotes: secondQuotes)

				self.setDataCount(data: [(firstinstrument, newfirstquotes), (secondinstrument, newsecondquotes)])
			}
		}
	}

	/**
	recallculationg values for two quote arrays
	- Author: Danila Ferents
	- Parameters:
	- firstquotes: quotes of first instrument
	- transactions: quotes of second instrument
	- Returns:
	*/
	func correlationQuotes(firstquotes: [Quote], secondquotes: [Quote]) -> ([(Double, Double)], [(Double, Double)]) {
		let maxfirstinstrument = firstquotes.max { (quote1, quote2) -> Bool in
			return quote1.exchangeRate < quote2.exchangeRate
		}?.exchangeRate
		let minfirstinstrument = firstquotes.min { (quote1, quote2) -> Bool in
			return quote1.exchangeRate < quote2.exchangeRate
		}?.exchangeRate
		let maxsecondinstrument = secondquotes.max { (quote1, quote2) -> Bool in
			return quote1.exchangeRate < quote2.exchangeRate
		}?.exchangeRate
		let minsecondinstrument = secondquotes.min { (quote1, quote2) -> Bool in
			return quote1.exchangeRate < quote2.exchangeRate
		}?.exchangeRate

		let newquotesfirstinstrument = firstquotes.map { (quote) -> (Double, Double) in
			return (Double(quote.timestamp), (quote.exchangeRate - (minfirstinstrument ?? 0)) / ((maxfirstinstrument ?? 1) - (minfirstinstrument ?? 0)))
		}

		let secondquotesfirstinstrument = secondquotes.map { (quote) -> (Double, Double) in
			return (Double(quote.timestamp), (quote.exchangeRate - (minsecondinstrument ?? 0)) / ((maxsecondinstrument ?? 1) - (minsecondinstrument ?? 0)))
		}
		return (newquotesfirstinstrument, secondquotesfirstinstrument)
	}
}
