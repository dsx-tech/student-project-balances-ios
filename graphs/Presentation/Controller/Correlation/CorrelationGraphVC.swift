//
//  CorrelationGraphVC.swift
//  graphs
//
//  Created by Danila Ferents on 19.02.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import Charts
import KeychainAccess

class CorrelationGraphVC: UIViewController, ChartViewDelegate {

	//Outlets
	@IBOutlet weak var chartView: LineChartView!
	@IBOutlet weak var startDateTextField: RoundedTextField!
	@IBOutlet weak var endDateTextField: RoundedTextField!
	let startDateDatePicker = UIDatePicker()
	let endDateDatePicker = UIDatePicker()
	@IBOutlet weak var switcherSegmentControl: UISegmentedControl!

	//Variables
	var vc: CorrelationVC!
	var firstInstrument: String!
	var secondInstrument: [String]!

	var firstQuotes: [QuotePeriod]!
	var secondQuotes: [QuotePeriod]!
	var start: String!
	var end: String!

	let quotesApi = TradeApi()
	let formatter = DateFormatter()

	var correlations: [String: ([Double], [Double])] = [:]

	override func viewDidLoad() {
		super.viewDidLoad()

		setUpDateTextFields()
		setUpGraph()
		setUpToolBar()

		if let start = formatter.date(from: "2019-01-01T00:00:01"), let end = formatter.date(from: "2020-04-09T23:59:59") {
			self.startDateDatePicker.date = start
			self.endDateDatePicker.date = end

			self.start = "2019-01-01T00:00:01"
			self.end = "2020-04-09T23:59:59"

			self.startDateTextField.text = "01.01.2019 00:00"
			self.endDateTextField.text = "09.04.2020 00:00"
			reloadData(start: "2019-01-01T00:00:01", end: "2020-04-09T23:59:59")
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
	func callculatecorrelation(firstinstrument: String, secondinstrument: String, startDate: Date, endDate: Date) {

		//number of months to count corellation, which we take from duration parameter

		var dateComponents = Calendar.current.dateComponents([Calendar.Component.month], from: startDate, to: endDate)

		let keychain = Keychain(service: "swagger")
		let baseCurrency = try? keychain.get("base_currency")

		let firstinstrumentWithBase = firstinstrument + "-" + (baseCurrency ?? "usd")
		let secondinstrumentWithBase = secondinstrument + "-" + (baseCurrency ?? "usd")

		//get quotes for first instrument
		quotesApi.getQuotesinPeriod(instruments: [firstinstrumentWithBase, secondinstrumentWithBase], startTime: startDate, endTime: endDate) { (quotes)  in

			guard let quotesArray = quotes,
				let firstQuotes = quotesArray[firstinstrumentWithBase],
				let secondQuotes = quotesArray[secondinstrumentWithBase] else {
					DispatchQueue.main.async {
						self.simpleAlert(title: "Error", msg: "No such quotes!")
					}
					print("Error in getting quotes for  instrument")
					return
			}

			let numberOfMonths = dateComponents.month ?? 0

			for i in 0..<numberOfMonths {
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
	func setUpDateTextFields() {

		self.startDateTextField.inputView = self.startDateDatePicker
		self.endDateTextField.inputView = self.endDateDatePicker
		self.startDateDatePicker.datePickerMode = .date
		self.endDateDatePicker.datePickerMode = .date
		let localeID = Locale.preferredLanguages.first
		self.startDateDatePicker.locale = Locale(identifier: localeID ?? "")
		self.endDateDatePicker.locale = Locale(identifier: localeID ?? "")

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		if let start = formatter.date(from: "2020-01-01T00:00:01"), let end = formatter.date(from: "2020-04-09T23:59:59") {
			self.startDateDatePicker.date = start
			self.endDateDatePicker.date = end

			self.startDateTextField.text = "01.01.2020 00:00"
			self.endDateTextField.text = "09.04.2020 00:00"
		}
	}

	func setUpToolBar() {

		let toolbarStart = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
		toolbarStart.barStyle = .default
		let toolbarEnd = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
		toolbarEnd.barStyle = .default
		toolbarStart.sizeToFit()
		toolbarEnd.sizeToFit()
		toolbarStart.tintColor = UIColor.blue
		toolbarEnd.tintColor = UIColor.blue

		toolbarStart.isUserInteractionEnabled = true
		toolbarEnd.isUserInteractionEnabled = true

		let doneActionStart = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneActionStartFunc))
		let cancelStart = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelFunc))

		let doneActionEnd = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneActionEndFunc))
		let cancelEnd = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelFunc))

		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

		toolbarStart.setItems([cancelStart, flexSpace, doneActionStart], animated: true)
		toolbarEnd.setItems([cancelEnd, flexSpace, doneActionEnd], animated: true)

		startDateTextField.inputAccessoryView = toolbarStart
		endDateTextField.inputAccessoryView = toolbarEnd
	}

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

		chartView.legend.form = .circle
	}
}

// - MARK: DatePickers

extension CorrelationGraphVC {

	@objc func doneActionStartFunc() {
		if startDateDatePicker.date > endDateDatePicker.date {
			self.simpleAlert(title: "Error!", msg: "Start date must be less than end date!")
		} else if startDateDatePicker.date > Date(timeIntervalSinceNow: 0) {
			self.simpleAlert(title: "Error!", msg: "Start date higher current!")
		} else {
			self.start = getDataFromStartPicker()
			reloadData(start: self.start, end: self.end)
			view.endEditing(true)
		}
	}

	@objc func doneActionEndFunc() {
		if startDateDatePicker.date > endDateDatePicker.date {
			self.simpleAlert(title: "Error!", msg: "End date must be higher than start date!")
		} else if endDateDatePicker.date > Date(timeIntervalSinceNow: 0) {
			self.simpleAlert(title: "Error!", msg: "End date higher current!")
		} else {
			self.end = getDataFromEndPicker()
			reloadData(start: self.start, end: self.end)
			view.endEditing(true)
		}
	}

	@objc func cancelFunc() {
		view.endEditing(true)
	}

	func getDataFromStartPicker() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy HH:mm"
		startDateTextField.text = formatter.string(from: startDateDatePicker.date)
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		return formatter.string(from: startDateDatePicker.date)
	}

	func getDataFromEndPicker() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy HH:mm"
		endDateTextField.text = formatter.string(from: endDateDatePicker.date)
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		return formatter.string(from: endDateDatePicker.date)
	}
}

// - MARK: GraphData
extension CorrelationGraphVC {
	func setDataCount(data: [String: ([Double], [Double])]) {

		var datasets: [LineChartDataSet] = []

		data.forEach { (asset, corellationWithDates) in
			let values = (0..<corellationWithDates.0.count).map { (i) -> ChartDataEntry in
				return ChartDataEntry(x: corellationWithDates.0[i], y: corellationWithDates.1[i])
			}

			let set = LineChartDataSet(entries: values, label: asset)
			set.drawIconsEnabled = false

			set.lineDashLengths = [5, 2.5]
			set.highlightLineDashLengths = [5, 2.5]
			set.setColor(.black)
			set.lineWidth = 1
			set.circleRadius = 2
			set.drawCircleHoleEnabled = false
			set.valueFont = .systemFont(ofSize: 9)
			set.formLineDashLengths = [5, 2.5]
			set.formLineWidth = 1
			set.formSize = 15

			let red = Double(arc4random_uniform(256))
			let green = Double(arc4random_uniform(256))
			let blue = Double(arc4random_uniform(256))
			let color = UIColor(red: CGFloat(red / 255), green: CGFloat(green / 255), blue: CGFloat(blue / 255), alpha: 1)

			let gradientColors = [UIColor(red: CGFloat(red / 255),
										  green: CGFloat(green / 255),
										  blue: CGFloat(blue / 255),
										  alpha: 0).cgColor,
								  color.cgColor]

			set.setCircleColor(color)

			guard let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil) else { return }

			set.fillAlpha = 1
			set.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
			set.drawFilledEnabled = true
			set.colors = [color]
			datasets.append(set)
		}

		DispatchQueue.main.async {
			let data = LineChartData(dataSets: datasets)
			self.chartView.data = data
		}
	}
}

// - MARK: Reload Data Functions

extension CorrelationGraphVC {
	func reloadData(start: String, end: String) {

		guard let startDate = formatter.date(from: start), let endDate = formatter.date(from: end) else { return }

		self.correlations = [:]
		self.secondInstrument.forEach { (instrument) in
			callculatecorrelation(firstinstrument: self.firstInstrument, secondinstrument: instrument, startDate: startDate, endDate: endDate)
		}
	}

	func checkDates() -> Bool {
		if self.start == nil {
			self.simpleAlert(title: "Error", msg: "Fill in Start and End Date!")
			return false
		}
		return true
	}
}
