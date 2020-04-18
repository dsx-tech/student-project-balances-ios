//
//  PieChartVC.swift
//  graphs
//
//  Created by Danila Ferents on 25.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit
import AAInfographics

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
}
//1
class PieChartVC: UIViewController {

	//Variables
	var chartView: AAChartView! //View in which Chart is drown

	var chartModel: AAChartModel! //Model
	//	var assetsApi = AssetsApi() //struct to handle Network connection

	var trades: [Trade]! //trades from backend
	var transactions: [Transaction]! //transactions from backend

	let tradesApi = TradeApi()

	override func viewDidLoad() {
		super.viewDidLoad()

		setUpChartView() //set size for view
		view.addSubview(chartView)

		//get all trades and transactions

		tradesApi.getAllTradesAndTransactions { (trades, transactions) in
			if let trades = trades, let transactions = transactions {
				self.trades = trades
				self.transactions = transactions

				let assets = ActiveCostAndPieApi.sharedManager.getAssetsForPie(trades: &self.trades, transactions: &self.transactions)

				self.chartModel = self.configurePieChartModel(data: assets)
				print(assets)
				DispatchQueue.main.async {
					self.chartView?.aa_drawChartWithChartModel(self.chartModel)
				}
			}
		}
	}

	private func setUpChartView() {
		chartView = AAChartView()

		let chartWidth = view.frame.size.width
		let chartHeight = view.frame.size.height
		chartView?.frame = CGRect(x: 0, y: 0, width: chartWidth, height: chartHeight)
		chartView?.contentHeight = view.frame.size.height - 80
		chartView?.scrollEnabled = false
	}

	private func configurePieChartModel(data: [Any]) -> AAChartModel {

		let colors = (0..<data.count).map { _ -> String in
			let color = UIColor(red: .random(),
								green: .random(),
								blue: .random(),
								alpha: 1.0)

			return color.toHexString()
		}

		return AAChartModel()
			.colorsTheme(colors)
			.chartType(.pie)
			.backgroundColor(AAColor.white)
			.title("Portfolio Assets")
			.dataLabelsEnabled(true)
			.series([
				AASeriesElement()
					.name("$")
					.innerSize("10%")
					.data(data)
			])

	}
}
