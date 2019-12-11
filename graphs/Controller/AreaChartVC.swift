//
//  AreaChartVC.swift
//  graphs
//
//  Created by Danila Ferents on 26.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit
import AAInfographics

class AreaChartVC: UIViewController {

	//Variables
	var chartView: AAChartView!
	var chartModel: AAChartModel!
	var timeassetApi = AssetsValueApi()

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpAreaChartView()
		view.addSubview(chartView!)
		let url = ""
		timeassetApi.getDataForTimeAssetChart(url: url) { (assets) in
			if let assets = assets {
				self.chartModel = self.configureAreaChartModel(data: assets.convertToArray())
				self.chartView!.aa_drawChartWithChartModel(self.chartModel)
			}
		}
		self.chartModel = self.configureAreaChartModel(data: [])
		self.chartView!.aa_drawChartWithChartModel(self.chartModel)
    }

	func setUpAreaChartView() {
		chartView = AAChartView()

		let charWidth = view.frame.size.width
		let charHeight = view.frame.size.height

		chartView!.frame = CGRect(x: 0, y: 60, width: charWidth, height: charHeight)
		chartView.contentHeight = charHeight - 80
		chartView!.scrollEnabled = false
	}

	func configureAreaChartModel(data: [Any]) -> AAChartModel {
		let stopsArr = [
			[0.0, "#febc0f"],//颜色字符串设置支持十六进制类型和 rgba 类型
			[0.5, "#FF14d4"],
			[1.0, "#0bf8f5"]
		]

		let gradientColorDic = AAGradientColor.linearGradient(direction: .toRight, stops: stopsArr)

		return AAChartModel().chartType(.areaspline)
			.title("Graph of the value of a specific asset in the base currency")
			.categories(["Dec", "Jan", "Febr", "May"])
//			.categories(data.first!)
			.backgroundColor("#FFFFFF")
			.markerRadius(0)
			.legendEnabled(false)
			.dataLabelsEnabled(false)
			.zoomType(AAChartZoomType.xy)
			.series([
				AASeriesElement()
				.name("$")
				.color(gradientColorDic)
//				.data(data.second)
					.data([7.0, 6.9, 5.6, 9.9])
				]
		)
	} 
}
