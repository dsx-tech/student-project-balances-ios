//
//  StackedBarChartVC.swift
//  graphs
//
//  Created by Danila Ferents on 10.12.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit
import Charts
import KeychainAccess

extension CGFloat {
	static func random() -> CGFloat {
		return CGFloat(arc4random()) / CGFloat(UInt32.max)
	}
}

enum ViewStack {
	case asset
	case procent
}

class StackedBarChartVC: UIViewController, ChartViewDelegate {

	//Outlets
	@IBOutlet weak var chartView: BarChartView!
	@IBOutlet weak var durationSegmentControl: UISegmentedControl!
	@IBOutlet weak var valueOrProcentSegmentControle: UISegmentedControl!
	@IBOutlet weak var startDateTextField: RoundedTextField!
	@IBOutlet weak var endDateTextField: RoundedTextField!

	@IBOutlet weak var portfolioTodayLbl: UILabel!
	@IBOutlet weak var highestNameLbl: UILabel!

	@IBOutlet weak var totalPortfolioLbl: UILabel!
	@IBOutlet weak var highestLbl: UILabel!

	@IBOutlet weak var portfolioBaseSymbolLbl: UILabel!
	@IBOutlet weak var highestBaseSymbolLbl: UILabel!

	let startDateDatePicker = UIDatePicker()
	let endDateDatePicker = UIDatePicker()

	//Variables
	var trades: [Trade]!
	var transactions: [Transaction]!
	let tradesApi = TradeApi()
	let formatterDate = DateFormatter()
	let syncCoordinator = SyncCoordinator()

	var data: ([(Date, [(String, Double)])], [String]) = ([], [])

	var start = "2014-01-01T00:00:01"
	var end = "2020-12-09T23:59:59"
	var duration: AssetLineChartDuration = .month
	var viewStack: ViewStack = .asset

	lazy var formatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = 1
		formatter.negativeSuffix = " " + (self.portfolioBaseSymbolLbl.text ?? "$")
		formatter.positiveSuffix = " " + (self.portfolioBaseSymbolLbl.text ?? "$")

		return formatter
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		//        chartView.legend = l
		setUpStackedChart()
		setUpDateTextFields()
		setUpToolBar()
		setUpBaseLbl()
		reloadData(start: "2014-01-01T00:00:01", end: "2020-12-09T23:59:59")
	}
}

// - MARK: Set Up Functions

extension StackedBarChartVC {
	func setUpBaseLbl() {
		let keychain = Keychain(service: "swagger")
		if let baseCurrencyLbl = keychain["base_currency_img"] {
			self.highestBaseSymbolLbl.text = baseCurrencyLbl
			self.portfolioBaseSymbolLbl.text = baseCurrencyLbl
		}
	}
	func setUpDateTextFields() {
		self.startDateTextField.inputView = self.startDateDatePicker
		self.endDateTextField.inputView = self.endDateDatePicker
		self.startDateDatePicker.datePickerMode = .date
		self.endDateDatePicker.datePickerMode = .date
		let localeID = Locale.preferredLanguages.first
		self.startDateDatePicker.locale = Locale(identifier: localeID ?? "")
		self.endDateDatePicker.locale = Locale(identifier: localeID ?? "")

		formatterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		if let start = formatterDate.date(from: "2014-01-01T00:00:01"), let end = formatterDate.date(from: "2020-12-09T23:59:59") {
			self.startDateDatePicker.date = start
			self.endDateDatePicker.date = end

			self.startDateTextField.text = "01.01.2014 00:00"
			self.endDateTextField.text = "09.12.2020 00:00"
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
	func setUpStackedChart() {
		chartView.delegate = self

		chartView.chartDescription?.enabled = false

		chartView.maxVisibleCount = 40
		chartView.drawBarShadowEnabled = false
		chartView.drawValueAboveBarEnabled = false
		chartView.highlightFullBarEnabled = false
		chartView.animate(xAxisDuration: 3)
		chartView.animate(yAxisDuration: 3)

		let leftAxis = chartView.leftAxis
		leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: self.formatter)
		leftAxis.axisMinimum = 0

		let xAxis = chartView.xAxis
		xAxis.labelPosition = .topInside
		xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
		xAxis.labelTextColor = .black
		xAxis.drawAxisLineEnabled = false
		xAxis.drawGridLinesEnabled = true
		xAxis.centerAxisLabelsEnabled = true

		let dateFormatter = DateValueFormatterNew()
		dateFormatter.start = self.start
		dateFormatter.duration = self.duration

		xAxis.valueFormatter = dateFormatter
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
	}
}

// - MARK: DatePickers

extension StackedBarChartVC {

	@objc func doneActionStartFunc() {
		if startDateDatePicker.date > endDateDatePicker.date {
			self.simpleAlert(title: "Error!", msg: "Start date must be less than end date!")
		} else {
			self.start = getDataFromStartPicker()

			self.reloadFormatter()

			reloadData(start: self.start, end: self.end)
			view.endEditing(true)
		}
	}

	@objc func doneActionEndFunc() {
		if startDateDatePicker.date > endDateDatePicker.date {
			self.simpleAlert(title: "Error!", msg: "End date must be higher than start date!")
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

// - MARK: ChartData

extension StackedBarChartVC {
	func setData(data: [(Date, [(String, Double)])], labels: [String]) {

		if self.valueOrProcentSegmentControle.selectedSegmentIndex == 0 {
			setHighestPortfolioCost(data: data)
		} else {
			setProcent(data: data, labels: labels)
		}

		let yVals = (0..<data.count).map { (i) -> BarChartDataEntry in

			var values = data[i].1.map { (value) -> Double in
				value.1
			}

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
		data.setValueFormatter(DefaultValueFormatter(formatter: self.formatter))
		data.setValueTextColor(.clear)

		chartView.fitBars = true
		chartView.data = data
		chartView.animate(xAxisDuration: 1.0)
	}

	func setHighestPortfolioCost(data: [(Date, [(String, Double)])]) {
		// set max cost monthly
		var maxportfolioCostInDuration = 0.0
		data.forEach { (month) in
			var inDurationPortfolioCost = 0.0
			month.1.forEach { (assetinBase) in
				inDurationPortfolioCost += assetinBase.1
			}
			if maxportfolioCostInDuration < inDurationPortfolioCost {
				maxportfolioCostInDuration = inDurationPortfolioCost
			}
		}

		let formatter = NumberFormatter()
		formatter.numberStyle = .none
		formatter.maximumFractionDigits = 3

		if let max = formatter.string(from: maxportfolioCostInDuration as NSNumber) {
			DispatchQueue.main.async {
				self.highestLbl.text = max
			}
		}

		var todayCost = 0.0
		
		if let last = data.last {

			last.1.forEach { (cost) in
				todayCost += cost.1
			}
		}

		DispatchQueue.main.async {

			self.portfolioTodayLbl.text = "Portfolio:"
			self.highestNameLbl.text = "Highest:"

			self.setUpBaseLbl()

			if let today = formatter.string(from: todayCost as NSNumber) {
				self.totalPortfolioLbl.text = today
			}
			if todayCost >= maxportfolioCostInDuration {
				self.totalPortfolioLbl.textColor = UIColor.systemGreen
			} else {
				self.totalPortfolioLbl.textColor = UIColor.systemRed
			}
		}
	}

	func setProcent(data: [(Date, [(String, Double)])], labels: [String]) {

		var procentAssetName = ""
		var procentAssetValue = 0.0

		if let last = data.last {

			for i in 0..<last.1.count where last.1[i].1 > procentAssetValue {
				procentAssetName = labels[i]
				procentAssetValue = last.1[i].1
			}
		}

		DispatchQueue.main.async {

			self.portfolioTodayLbl.text = "Highest Asset:"
			self.highestNameLbl.text = "Value:"
			self.portfolioBaseSymbolLbl.text = "%"
			self.highestBaseSymbolLbl.text = "%"

			if procentAssetName.isEmpty {
				self.totalPortfolioLbl.text = "--"
			} else {
				self.totalPortfolioLbl.text = procentAssetName
			}

			let formatter = NumberFormatter()
			formatter.numberStyle = .none
			formatter.maximumFractionDigits = 4

			if let procent = formatter.string(from: procentAssetValue as NSNumber) {
				DispatchQueue.main.async {
					self.highestLbl.text = String(procent)
				}
			}
			self.procentFormatter()
		}
	}
}

// - MARK: reloadData

extension StackedBarChartVC {

	func reloadFormatter() {
		let newvalueformatter = DateValueFormatterNew()
		newvalueformatter.start = self.start
		newvalueformatter.duration = self.duration

		self.chartView.xAxis.valueFormatter = newvalueformatter
	}

	func reloadData(start: String, end: String) {

		self.tradesApi.getAllTradesAndTransactions { (trades, transactions) in
			if let transactions = transactions, let trades = trades {

				self.trades = trades
				self.transactions = transactions
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

//				let (assets, labels) = ActiveCostAndPieApi.sharedManager.getAssetsInDurationForStack(trades: &self.trades,
//																									 transactions: &self.transactions,
//																									 duration: self.duration,
//																									 start: start,
//																									 end: end)

				let (assets, labels) = ActiveCostAndPieApi.sharedManager.changeAssetsInDurationForStack(trades: &self.trades,
				transactions: &self.transactions,
				duration: self.duration,
				start: start,
				end: end)

				self.syncCoordinator.getAndSyncQuotesInPeriod(assets: labels,
															  start: dateFormatter .date(from: start) ?? Date(),
															  end: dateFormatter.date(from: end) ?? Date(),
															  duration: "monthly") { (quotes) in
																let newassets = ActiveCostAndPieApi.sharedManager.getAssetsInDurationForStackQuotes(assets: assets, quotes: quotes ?? [:])
																	DispatchQueue.main.async {
																		if !labels.isEmpty {
																			self.setData(data: newassets, labels: labels)
																			self.data = (newassets, labels)
																		} else {
																			self.chartView.data = nil
																			self.data = ([], [])
																		}
																	}
				}
			}
		}
	}

}

// - MARK: SegmentControl

extension StackedBarChartVC {
	@IBAction func indexChanged(_ sender: Any) {
		switch self.durationSegmentControl.selectedSegmentIndex {
		case 0:
			setUpMonthly()
		case 1:
			setUpYearly()
		default:
			print("Error in segment control!")
		}
	}

	func setUpMonthly() {
		self.duration = .month
		self.reloadFormatter()
		self.reloadData(start: self.start, end: self.end)
	}

	func setUpYearly() {
		self.duration = .year
		self.reloadFormatter()
		self.reloadData(start: self.start, end: self.end)
	}

	@IBAction func valueIndexChanged(_ sender: Any) {
		switch self.valueOrProcentSegmentControle.selectedSegmentIndex {
		case 0:
			setUpValue()
		case 1:
			setUpProcents()
		default:
			print("Error in segment control!")
		}
	}

	func setUpValue() {
		self.setData(data: self.data.0, labels: self.data.1)
	}

	func setUpProcents() {

		var procentData: ([(Date, [(String, Double)])], [String]) = ([], self.data.1)

		self.data.0.forEach { (period) in

			var summvalue = 0.0

			for i in 0..<period.1.count {
				summvalue += period.1[i].1
			}

			var valuesInProcent: [(String, Double)] = []

			period.1.forEach { (value) in
				let valueInProcent = (value.1 / summvalue) * 100
				valuesInProcent.append(("", valueInProcent))
			}
			procentData.0.append((period.0, valuesInProcent))
		}
		self.setData(data: procentData.0, labels: procentData.1)

	}

	func procentFormatter() {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = 1
		formatter.negativeSuffix = " " + (self.portfolioBaseSymbolLbl.text ?? "$")
		formatter.positiveSuffix = " " + (self.portfolioBaseSymbolLbl.text ?? "$")
		self.formatter = formatter
	}
}
