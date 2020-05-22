//
//  PieChartVCCharts.swift
//  graphs
//
//  Created by Danila Ferents on 08.12.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit
import Charts
import iOSDropDown
import KeychainAccess

enum AssetLineChartDuration {
	case day
	case month
	case year
}

class LineChartVCCharts: UIViewController, ChartViewDelegate {
	//Outlets
	@IBOutlet weak var chartView: LineChartView!
	@IBOutlet weak var assetsValueLbl: UILabel!
	@IBOutlet weak var baseassetLbl: UILabel!
	@IBOutlet weak var assetsNameTextField: DropDown!
	@IBOutlet weak var startDateTextField: RoundedTextField!
	@IBOutlet weak var durationSegmentedControl: UISegmentedControl!
	let startDateDatePicker = UIDatePicker()
	let endDateDatePicker = UIDatePicker()
	@IBOutlet weak var endDateTextField: RoundedTextField!

	//Variables
	var trades: [Trade]!
	var transactions: [Transaction]!
	let tradesApi = TradeApi()
	let syncCoordinator = SyncCoordinator()
	var assetsInPortfolio: [String: ([Double], [Double])]!
	let formatter = DateFormatter()

	var asset = "usd"
	var start = "2014-01-01T00:00:01"
	var end = "2020-12-09T23:59:59"
	var duration: AssetLineChartDuration = .month

	override func viewDidLoad() {
		super.viewDidLoad()

		setUpBaseLbl()
		setUpChartView()
		setUpDropDown()
		setUpDateTextFields()
		setUpToolBar()

		self.reloadData(start: self.start, end: self.end)
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		setUpBaseLbl()
	}
}

// - MARK: Set up functions

extension LineChartVCCharts {
	func setUpBaseLbl() {
		let keychain = Keychain(service: "swagger")
		if let baseCurrencyLbl = keychain["base_currency_img"] {
			self.baseassetLbl.text = baseCurrencyLbl
		}
	}
	func setUpDropDown() {
		self.assetsNameTextField.optionArray = assets
		self.assetsNameTextField.text = "usd"
		self.assetsNameTextField.didSelect { (selectedAsset, _, _) in
			self.asset = selectedAsset
			self.setDataCount(asset: selectedAsset)
		}
		self.assetsNameTextField.layer.cornerRadius = 10
		self.assetsNameTextField.backgroundColor = UIColor.white
		self.assetsNameTextField.layer.borderColor = UIColor.gray.cgColor
		self.assetsNameTextField.layer.borderWidth = 1.0
		self.assetsNameTextField.clipsToBounds = true
	}
	func setUpChartView() {
		chartView.delegate = self

		chartView.chartDescription?.enabled = false
		chartView.dragEnabled = true
		chartView.setScaleEnabled(true)
		chartView.pinchZoomEnabled = true
		chartView.animate(xAxisDuration: 0.5, easingOption: .easeInOutBounce)

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

	func setUpDateTextFields() {

		self.startDateTextField.inputView = self.startDateDatePicker
		self.endDateTextField.inputView = self.endDateDatePicker
		self.startDateDatePicker.datePickerMode = .date
		self.endDateDatePicker.datePickerMode = .date
		let localeID = Locale.preferredLanguages.first
		self.startDateDatePicker.locale = Locale(identifier: localeID ?? "")
		self.endDateDatePicker.locale = Locale(identifier: localeID ?? "")

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		if let start = formatter.date(from: "2014-01-01T00:00:01"), let end = formatter.date(from: "2020-12-09T23:59:59") {
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
}

// - MARK: DatePickers

extension LineChartVCCharts {

	@objc func doneActionStartFunc() {
		if startDateDatePicker.date > endDateDatePicker.date {
			self.simpleAlert(title: "Error!", msg: "Start date must be less than end date!")
		} else {
			self.start = getDataFromStartPicker()
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

// - MARK: Chart Data functions

extension LineChartVCCharts {
	func setDataCount(asset: String) {

		var datasets: [LineChartDataSet] = []

		guard let data = self.assetsInPortfolio else {
			print("No data in class")
			return
		}

		guard let newdata = data[asset] else {
			simpleAlert(title: "Error", msg: "No asset in potrfolio!")
			self.assetsValueLbl.text = "--"
			chartView.data = nil
			return
		}

		let values = (0..<newdata.0.count).map { (i) -> ChartDataEntry in
			let x = newdata.1[i]
			let y = newdata.0[i]
			let entry = ChartDataEntry(x: x, y: y)
			return entry
		}

		let formatter = NumberFormatter()
		formatter.numberStyle = .none
		formatter.maximumFractionDigits = 3

		if let lastvalue = newdata.0.last {
			if let assetvalue = formatter.string(from: lastvalue as NSNumber) {
				self.assetsValueLbl.text = assetvalue
			}
		}

		let set1 = LineChartDataSet(entries: values, label: asset)
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

		let chartdata = LineChartData(dataSets: datasets)

		chartView.data = chartdata
	}
}

// - MARK: Reload Data

extension LineChartVCCharts {
	
	func reloadData(start: String, end: String) {
		self.tradesApi.getAllTradesAndTransactions { (trades, transactions) in
			if let transactions = transactions, let trades = trades {
				self.trades = trades
				self.transactions = transactions

				self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

				let (assetsInDuration, currencies) = ActiveCostAndPieApi.sharedManager.getAssetsForActiveCost(trades: &self.trades,
																							 transactions: &self.transactions,
																							 start: start,
																							 end: end,
																							 duration: self.duration)
				switch self.duration {
				case .day:
					DispatchQueue.main.async {
						self.assetsInPortfolio = assetsInDuration
						self.setDataCount(asset: self.asset)
					}
				case .month:
					self.syncCoordinator.getAndSyncQuotesInPeriod(assets: Array(currencies),
																  start: self.formatter.date(from: start) ?? Date(),
																  end: self.formatter.date(from: end) ?? Date(),
																  duration: "monthly") { (quotes) in
						let assetsMonthlyWithQuotes = ActiveCostAndPieApi.sharedManager.getAssetsForActiveCostWithQuotes(assets: assetsInDuration, quotes: quotes ?? [:])
						DispatchQueue.main.async {
							self.assetsInPortfolio = assetsMonthlyWithQuotes
							self.setDataCount(asset: self.asset)
						}
					}
				case.year:
					DispatchQueue.main.async {
						self.assetsInPortfolio = assetsInDuration
						self.setDataCount(asset: self.asset)
					}
				}
			}
		}
	}
}

// - MARK: SegmentControl

extension LineChartVCCharts {
	@IBAction func indexChanged(_ sender: Any) {
		switch self.durationSegmentedControl.selectedSegmentIndex {
		case 0:
			setUpDaily()
		case 1:
			setUpMonthly()
		case 2:
			setUpYearly()
		default:
			print("Error in segment control!")
		}
	}

	func setUpDaily() {
		self.duration = .day
		self.reloadData(start: self.start, end: self.end)
	}

	func setUpMonthly() {
		self.duration = .month
		self.reloadData(start: self.start, end: self.end)
	}

	func setUpYearly() {
		self.duration = .year
		self.reloadData(start: self.start, end: self.end)
	}
}
