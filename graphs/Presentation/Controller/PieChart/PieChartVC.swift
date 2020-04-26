//
//  PieChartVC.swift
//  graphs
//
//  Created by Danila Ferents on 25.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit
import Charts

extension UIColor {
	func toHexString() -> String {
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0

		getRed(&r, green: &g, blue: &b, alpha: &a)

		let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0

		return String(format: "#%06x", rgb)
	}

	convenience init(hex: Int, alpha: CGFloat = 1.0) {
	let r = CGFloat((hex >> 16) & 0xff) / 255
			let g = CGFloat((hex >> 08) & 0xff) / 255
			let b = CGFloat((hex >> 00) & 0xff) / 255
		self.init(red: r, green: g, blue: b, alpha: alpha)
	}
}

class PieChartVC: UIViewController {

	//Variables
//	var chartView: AAChartView! //View in which Chart is drown
	@IBOutlet weak var viewPlace: PieChartView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var viewVP: UIView!

	//	var assetsApi = AssetsApi() //struct to handle Network connection

	var trades: [Trade]! //trades from backend
	var transactions: [Transaction]! //transactions from backend
	var assets: [(String, Double)]!

	let tradesApi = TradeApi()

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpPieChart()
		setUpTableView()
		//get all trades and transactions
		self.view.backgroundColor = AppColors.Gray
		updateData()
	}
}

// - MARK: PieChartSetUp

extension PieChartVC {

	private func customiseChart(data: [(String, Double)]) -> PieChartData {

		var dataEntries: [ChartDataEntry] = []
		var summ = 0.0
		data.forEach { (asset, value) in
			if !value.isLessThanOrEqualTo(0.0) {
				let dataEntry = PieChartDataEntry(value: value, label: asset, data: asset)
				dataEntries.append(dataEntry)
			}
			summ += value
		}
		let formatter = NumberFormatter()
		formatter.numberStyle = .none
		formatter.maximumFractionDigits = 3

		if let summ = formatter.string(from: summ as NSNumber) {
			self.viewPlace.centerText = summ + "$"
		}

		let marker = BalloonMarker(color: UIColor(white: 180 / 255, alpha: 1),
								   font: .systemFont(ofSize: 12),
								   textColor: .white,
								   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
		self.viewPlace.marker = marker

		let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
		pieChartDataSet.colors = ChartColorTemplates.vordiplom()
		+ ChartColorTemplates.joyful()
		+ ChartColorTemplates.colorful()
		+ ChartColorTemplates.liberty()
		+ ChartColorTemplates.pastel()
		+ [UIColor(red: 51 / 255, green: 181 / 255, blue: 229 / 255, alpha: 1)]

		let pieChartData = PieChartData(dataSet: pieChartDataSet)
		pieChartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
		pieChartData.setDrawValues(false)

		return pieChartData
	}

	private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
	  var colors: [UIColor] = []
	  for _ in 0..<numbersOfColor {
		let red = Double(arc4random_uniform(256))
		let green = Double(arc4random_uniform(256))
		let blue = Double(arc4random_uniform(256))
		let color = UIColor(red: CGFloat(red / 255),
							green: CGFloat(green / 255),
							blue: CGFloat(blue / 255),
							alpha: 1)
		colors.append(color)
	  }
	  return colors
	}

	func setUpPieChart() {
		self.viewPlace.drawEntryLabelsEnabled = false
		self.viewPlace.legend.horizontalAlignment = .right
		self.viewPlace.legend.verticalAlignment = .top
		self.viewPlace.legend.orientation = .vertical
		self.viewPlace.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
		self.viewPlace.layer.cornerRadius = 50
	}
}

// - MARK: TableViewDelegate

extension PieChartVC: UITableViewDelegate {
	func setUpTableView() {
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
		self.tableView.layer.cornerRadius = 50
		self.viewVP.layer.cornerRadius = 50
		self.tableView.register(UINib(nibName: String(describing: PieChartCell.self), bundle: nil), forCellReuseIdentifier: Identifiers.pieChartCell)
	}
	
}

// - MARK: TableViewDataSource

extension PieChartVC: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		/// Create the view.
		let headerView = UIView()
		headerView.backgroundColor = .clear

		/// Return view.
		return headerView
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return self.assets?.count ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.pieChartCell, for: indexPath) as? PieChartCell {
			let data = self.assets[indexPath.section]
			cell.configureCell(asset: data.0, value: data.1)
			return cell
		}
		return UITableViewCell()
	}
}

extension PieChartVC {
	func updateData() {
		tradesApi.getAllTradesAndTransactions { (trades, transactions) in
			if let trades = trades, let transactions = transactions {
				self.trades = trades
				self.transactions = transactions

				let (assets, currencies) = ActiveCostAndPieApi.sharedManager.getAssetsForPie(trades: &self.trades, transactions: &self.transactions)

				self.tradesApi.getTickerQuotes(instruments: currencies) { (quotes) in
					let assets = ActiveCostAndPieApi.sharedManager.getAssetsForPieWithQuotes(assets: assets, quotes: quotes ?? [:])

					let filteredAssets = assets.filter({ (asset) -> Bool in
						return !asset.1.isLess(than: 0.0)
					})

					let sortedAssets = filteredAssets.sorted { (asset1, asset2) -> Bool in
						return asset1.1 > asset2.1
					}

					self.assets = sortedAssets
					let chartData = self.customiseChart(data: assets)
					//				print(assets)
					DispatchQueue.main.async {
						self.viewPlace.data = chartData
						self.tableView.reloadData()
					}
				}
			}
		}
	}
}
