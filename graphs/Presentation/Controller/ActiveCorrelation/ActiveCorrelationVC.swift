//
//  ActiveCorrelationVC.swift
//  graphs
//
//  Created by Danila Ferents on 03.03.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import Charts
import iOSDropDown
import KeychainAccess

class ActiveCorrelationVC: UIViewController, ChartViewDelegate {

	//Outlets
	@IBOutlet weak var chartView: LineChartView!
	@IBOutlet weak var startDateTextField: RoundedTextField!
	@IBOutlet weak var endDateTExtField: RoundedTextField!
	let startDateDatePicker = UIDatePicker()
	let endDateDatePicker = UIDatePicker()
	@IBOutlet weak var firstAsset: DropDown!
	@IBOutlet weak var secondAsset: DropDown!

	//Variables
	var firstAssetName: String!
	var secondAssetName: String!
	var start: Date!
	var end: Date!

	let quotesApi = TradeApi()
	let syncCoordinator = SyncCoordinator()
	let formatter = DateFormatter()

	override func viewDidLoad() {
		super.viewDidLoad()

		setUpChart()
		setUpDropDown()
		setUpToolBar()
		setUpDateTextFields()
	}
}

// - MARK: GraphData

extension ActiveCorrelationVC {

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
	func correlationBetween(firstinstrument: String, secondinstrument: String, startDate: Date, endDate: Date) {

		//number of months to count corellation, which we take from duration parameter

		let keychain = Keychain(service: "swagger")
		let baseCurrency = try? keychain.get("base_currency")

		let firstinstrumentWithBase = firstinstrument + "-" + (baseCurrency ?? "usd")
		let secondinstrumentWithBase = secondinstrument + "-" + (baseCurrency ?? "usd")

		//get quotes for first instrument
		self.syncCoordinator.getAndSyncQuotesInPeriod(assets: [firstinstrumentWithBase, secondinstrumentWithBase],
													  start: startDate,
													  end: endDate,
													  duration: "daily") { (quotes) in
			guard let quotesArray = quotes,
				let firstQuotes = quotesArray[firstinstrumentWithBase],
				let secondQuotes = quotesArray[secondinstrumentWithBase] else {
					DispatchQueue.main.async {
						self.simpleAlert(title: "Error!", msg: "No such quotes!")
					}
					print("Error in getting quotes for  instrument")
					return
			}

			let (newfirstquotes, newsecondquotes) = CorrelationApi.sharedManager.correlationQuotesNormed(firstquotes: firstQuotes, secondquotes: secondQuotes)

			DispatchQueue.main.async {
				self.setDataCount(data: [(firstinstrument, newfirstquotes), (secondinstrument, newsecondquotes)])
			}
		}
	}

	func setDataCount(data: [(String, [(Double, Double)])]) {

		var datasets: [LineChartDataSet] = []

		data.forEach { (instrument, normallisedquotesWithDates) in
			let values = (0..<normallisedquotesWithDates.count).map { (i) -> ChartDataEntry in
				return ChartDataEntry(x: normallisedquotesWithDates[i].0, y: normallisedquotesWithDates[i].1)
			}

			let set = LineChartDataSet(entries: values, label: instrument)
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
			set.colors = [color]

			guard let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil) else { return }

			set.fillAlpha = 1
			set.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
			set.drawFilledEnabled = true
			datasets.append(set)
		}
		
		let data = LineChartData(dataSets: datasets)
		chartView.data = data
	}
}

// - MARK: Set Up Functions

extension ActiveCorrelationVC {

	func setUpChart() {

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

	func setUpDateTextFields() {

		self.startDateTextField.inputView = self.startDateDatePicker
		self.endDateTExtField.inputView = self.endDateDatePicker
		self.startDateDatePicker.datePickerMode = .date
		self.endDateDatePicker.datePickerMode = .date
		let localeID = Locale.preferredLanguages.first
		self.startDateDatePicker.locale = Locale(identifier: localeID ?? "")
		self.endDateDatePicker.locale = Locale(identifier: localeID ?? "")

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
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
		endDateTExtField.inputAccessoryView = toolbarEnd
	}

	func setUpDropDown() {

		self.firstAsset.optionArray = assets
		self.firstAsset.didSelect { (selectedAsset, _, _) in
			self.firstAssetName = selectedAsset
			self.reloadData()
		}

		self.firstAsset.layer.cornerRadius = 10
		self.firstAsset.backgroundColor = UIColor.white
		self.firstAsset.layer.borderColor = UIColor.gray.cgColor
		self.firstAsset.layer.borderWidth = 1.0
		self.firstAsset.clipsToBounds = true

		self.secondAsset.optionArray = assets
		self.secondAsset.didSelect { (selectedAsset, _, _) in
			self.secondAssetName = selectedAsset
			self.reloadData()
		}

		self.secondAsset.layer.cornerRadius = 10
		self.secondAsset.backgroundColor = UIColor.white
		self.secondAsset.layer.borderColor = UIColor.gray.cgColor
		self.secondAsset.layer.borderWidth = 1.0
		self.secondAsset.clipsToBounds = true
	}
}

// - MARK: DatePickers

extension ActiveCorrelationVC {

	@objc func doneActionStartFunc() {
		if startDateDatePicker.date > endDateDatePicker.date {
			self.simpleAlert(title: "Error!", msg: "Start date must be less than end date!")
		} else {
			getDataFromStartPicker()
			self.start = startDateDatePicker.date

			self.reloadData()
			view.endEditing(true)
		}
	}

	@objc func doneActionEndFunc() {
		if startDateDatePicker.date > endDateDatePicker.date {
			self.simpleAlert(title: "Error!", msg: "End date must be higher than start date!")
		} else {
			getDataFromEndPicker()
			self.end = endDateDatePicker.date

			self.reloadData()
			view.endEditing(true)
		}
	}

	@objc func cancelFunc() {
		view.endEditing(true)
	}

	func getDataFromStartPicker() {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy HH:mm"
		startDateTextField.text = formatter.string(from: startDateDatePicker.date)
	}

	func getDataFromEndPicker() {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy HH:mm"
		endDateTExtField.text = formatter.string(from: endDateDatePicker.date)
	}
}

// - MARK: Reload Data

extension ActiveCorrelationVC {
	func reloadData() {
		if let first = self.firstAssetName, let second =
			self.secondAssetName, let start = self.start, let end = self.end {
			self.correlationBetween(firstinstrument: first, secondinstrument: second, startDate: start, endDate: end)
		}
	}
}
