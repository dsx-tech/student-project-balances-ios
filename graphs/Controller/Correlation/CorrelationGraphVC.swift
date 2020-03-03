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
	var firstQuotes: [Quote]!
	var secondQuotes: [Quote]!

	var correlations: [String: ([Double], [Double])] = [:]

	override func viewDidLoad() {
        super.viewDidLoad()

		chartView.delegate = self

		let formatter = DateFormatter()

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		guard let start = formatter.date(from: "2018-01-01T00:00:01") else {return}
		

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

		let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
								   font: .systemFont(ofSize: 12),
								   textColor: .white,
								   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
		marker.chartView = chartView
		marker.minimumSize = CGSize(width: 80, height: 40)
		chartView.marker = marker

		chartView.legend.form = .line
		secondInstrument.forEach { (instrument) in
			callculatecorrelation(firstinstrument: self.firstInstrument, secondinstrument: instrument, startDate: start, duration: .sixmonths)
		}
    }
    
	func setDataCount(data: [String: ([Double],[Double])]) {

			var datasets:[LineChartDataSet] = []

		data.forEach { (instrument, corellationWithDates) in
			let values = (0..<corellationWithDates.0.count).map { (i) -> ChartDataEntry in
				return ChartDataEntry(x: corellationWithDates.0[i], y: corellationWithDates.1[i])
					}

			let set1 = LineChartDataSet(entries: values, label: data.first!.key)
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
			}
			let data = LineChartData(dataSets: datasets)

			chartView.data = data
		}


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
		func callculatecorrelation(firstinstrument: String, secondinstrument: String, startDate: Date, duration: durationQuotes) {

			//number of months to count corellation, which we take from duration parameter
			var dateComponents =  DateComponents()
			switch duration {

			case .month:
				dateComponents.month = 1
			case .threemonths:
				dateComponents.month = 3
			case .sixmonths:
				dateComponents.month = 6
			case .year:
				dateComponents.month = 12
			@unknown default:
				dateComponents.month = 0
			}

			guard let enddate = Calendar.current.date(byAdding: dateComponents, to: startDate) else {
				print("Error in converting end date.")
				return
			}
			//get quotes for first instrument
			let quotesApi = TradeApi()
			quotesApi.getQuotesinPeriod(url: Urls.quotesurl, instrument: firstinstrument, startTime: startDate, endTime: enddate) { (firstinstrumentquotes) in
				quotesApi.getQuotesinPeriod(url: Urls.quotesurl, instrument: secondinstrument, startTime: startDate, endTime: enddate) { (secondinstrumentquotes) in
					guard let firstQuotes = firstinstrumentquotes, let secondQuotes = secondinstrumentquotes else {
						print("Error in getting quotes for  instrument")
						return
					}
					//				let correlation = self.correlationQuotes(firstquotes: firstQuotes, secondquotes: secondQuotes)

					let numberOfMinths = dateComponents.month ?? 0
				//						print(numberOfMinths)

						for i in 0..<numberOfMinths {
							dateComponents.month = i
							let newdate = Calendar.current.date(byAdding: dateComponents, to: startDate)!
							let correl = self.correlationQuotes(firstquotes: firstQuotes.filter({ (quote) -> Bool in
								return quote.timestamp <= Int64(newdate.timeIntervalSince1970)
							}), secondquotes: secondQuotes.filter({ (quote) -> Bool in
								return quote.timestamp <= Int64(newdate.timeIntervalSince1970)
							}))

							if let _ = self.correlations[secondinstrument] {
								self.correlations[secondinstrument]!.0.append(newdate.timeIntervalSince1970)
								self.correlations[secondinstrument]!.1.append(correl)
							} else {
								self.correlations[secondinstrument] = ([newdate.timeIntervalSince1970],[correl])
							}

						}
					self.setDataCount(data: self.correlations)

				}
			}

		}

		/**
		callculationg correlation for two quote arrays
		cov(x,y)/((Standard Deviation1)*(Standard Deviation2)
		- Author: Danila Ferents
		- Parameters:
		- firstquotes: quotes of first instrument
		- transactions: quotes of second instrument
		- Returns: Double
		*/
		func correlationQuotes(firstquotes: [Quote], secondquotes: [Quote]) -> Double {
			var firstaverage = firstquotes.reduce(0) { (result, quote) -> Double in
				return result + quote.exchangeRate
			}

			var secondaverage = secondquotes.reduce(0) { (result, quote) -> Double in
				return result + quote.exchangeRate
			}

			var cov = 0.0
			var sizequotes = 0
			if firstquotes.count < secondquotes.count {
				sizequotes = firstquotes.count
			} else {
				sizequotes = secondquotes.count
			}

			firstaverage = firstaverage / Double(sizequotes)
			secondaverage = secondaverage / Double(sizequotes)

			for i in 0..<sizequotes {
				cov = cov + (firstquotes[i].exchangeRate - firstaverage) * (secondquotes[i].exchangeRate - secondaverage)
			}

			var sumfirst = 0.0
			for i in 0..<sizequotes {
				sumfirst = sumfirst + pow(firstquotes[i].exchangeRate - firstaverage, 2)
			}

			var sumsecond = 0.0
			for i in 0..<sizequotes {
				sumsecond = sumsecond + pow(secondquotes[i].exchangeRate - secondaverage, 2)
			}

			let denominator = pow(sumfirst * sumsecond, 0.5)

			let correl = cov/denominator
			if correl.isNaN {
				return 0.0
			} else {
				return correl
			}
		}
}
