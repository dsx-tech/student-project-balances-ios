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

	@IBOutlet weak var yearTextFiled: RoundedTextField!
	let yearDatePicker = UIPickerView()
    var years: [Int]!
    var year = Calendar.current.component(.year, from: Date()) {
        didSet {
			if let index = years.firstIndex(of: year) {
				yearDatePicker.selectRow(index, inComponent: 0, animated: true)
			}
        }
    }

	//Variables
	var transactions: [Transaction]!
	var start: String!
	var end: String!

	let tradesApi = TradeApi()
	let transactionsApi = TransactionApi()
	let formatter = DateFormatter()

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
		setUpDateTextFields()
		setUpToolBar()

    }
}

// - MARK: Graph Data

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

	//		guard let maxdeposit = dateDepositWithdraw.max(by: { (first, second) -> Bool in
	//			return first.value.0 > second.value.0 }) else {return}
	//		chartView.rightAxis.axisMaximum = maxdeposit.value.0
	//
	//		guard let maxwithdraw = dateDepositWithdraw.max(by: { (first, second) -> Bool in
	//			return first.value.1 > second.value.1 }) else {return}
	//		chartView.rightAxis.axisMinimum = maxwithdraw.value.1
			DispatchQueue.main.async {
				self.chartView.data = data
				self.chartView.setNeedsDisplay()
			}
		}
}

// - MARK: Set Up functions

extension VC10 {
	func setUpDateTextFields() {

		self.yearTextFiled.inputView = self.yearDatePicker

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		self.start = "2019-01-01T00:00:01"
		self.end = "2020-12-31T23:59:59"

		self.commonSetup()
	}

	func setUpToolBar() {

		let toolbarYear = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
		toolbarYear.barStyle = .default
		toolbarYear.sizeToFit()
		toolbarYear.tintColor = UIColor.blue

		toolbarYear.isUserInteractionEnabled = true

		let doneActionYear = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneActionYearFunc))
		let cancelYear = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelFunc))

		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

		toolbarYear.setItems([cancelYear, flexSpace, doneActionYear], animated: true)

		yearTextFiled.inputAccessoryView = toolbarYear
	}

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

		xAxis.valueFormatter = DateValueFormatter10()

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

// - MARK: DatePickers

extension VC10 {

	@objc func doneActionYearFunc() {

		let currentYear = Calendar.current.component(.year, from: Date(timeIntervalSinceNow: 0) as Date)

		if currentYear == years[self.yearDatePicker.selectedRow(inComponent: 0)] {
			getDataFromCurrentYear()
		} else {
			getDataFromPicker()
		}
		self.updateFormatter()
		self.yearTextFiled.text = String(years[self.yearDatePicker.selectedRow(inComponent: 0)])
		reloadData(start: self.start, end: self.end)
		view.endEditing(true)
	}

	@objc func cancelFunc() {
		view.endEditing(true)
	}

	func getDataFromPicker() {
		let year = self.years[self.yearDatePicker.selectedRow(inComponent: 0)]
		self.start = "\(year)-01-01T00:00:01"
		self.end = "\(year)-12-31T23:59:59"
	}

	func getDataFromCurrentYear() {

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		let year = self.years[self.yearDatePicker.selectedRow(inComponent: 0)]
		self.start = "\(year)-01-01T00:00:01"
		self.end = formatter.string(from: Date(timeIntervalSinceNow: 0))
	}
}

// - MARK: Graph Data

extension VC10 {
	func reloadData(start: String, end: String) {
		tradesApi.getAllTransactions(completion: { (transactions) in
			if let transactions = transactions {
				self.transactions = transactions
			}

			self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

			let start = self.formatter.date(from: start)
			let end = self.formatter.date(from: end)

			let balances = self.transactionsApi.getDatafromTransactions(transactions: &self.transactions, interval: .month, start: start ?? Date(), end: end ?? Date())

			self.setChartData(dateDepositWithdraw: balances)
		})
	}

	func updateFormatter() {
		let newValueFormatter = DateValueFormatter10()
		newValueFormatter.start = self.start
		self.chartView.xAxis.valueFormatter = newValueFormatter
	}
}

// - MARK: formatter

extension VC10: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(format: "%03.0f", value)
    }
}

// - MARK: PickerView

extension VC10: UIPickerViewDelegate, UIPickerViewDataSource {

    func commonSetup() {
        // population years
        var years: [Int] = []
		let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		
        if years.isEmpty {
            var year = calendar.component(.year, from: Date(timeIntervalSinceNow: 0) as Date)
            for _ in 1...30 {
                years.append(year)
                year -= 1
            }
        }
        self.years = years

		yearDatePicker.delegate = self
        yearDatePicker.dataSource = self

        let currentYear = calendar.component(.year, from: Date(timeIntervalSinceNow: 0) as Date)
        yearDatePicker.selectRow(currentYear - 1, inComponent: 0, animated: false)
    }

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch component {
		case 0:
			return self.years.count
		default:
			print("Strange component in Years!")
			return 0
		}
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(years[row])"
        default:
            return nil
        }
	}
}
