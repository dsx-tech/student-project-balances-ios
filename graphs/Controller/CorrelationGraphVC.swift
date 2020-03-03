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
	var secondInstrument: String!
	var firstQuotes: [Quote]!
	var secondQuotes: [Quote]!

	override func viewDidLoad() {
        super.viewDidLoad()

		chartView.delegate = self

		chartView.chartDescription?.enabled = false
		chartView.dragEnabled = true
		chartView.setScaleEnabled(true)
		chartView.pinchZoomEnabled = true

		chartView.xAxis.gridLineDashLengths = [10, 10]
		chartView.xAxis.gridLineDashPhase = 0

		let leftAxis = chartView.leftAxis
		leftAxis.axisMaximum = 55
		leftAxis.axisMinimum = 0
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

    }
    
	func setDataCount(data: [String: ([Double],[Double])]) {

			var datasets:[LineChartDataSet] = []

	//		for (asset, values) in data {
				let values = (0..<data["USD"]!.0.count).map { (i) -> ChartDataEntry in
					return ChartDataEntry(x: data["USD"]!.1[i], y: data["USD"]!.0[i])
				}

				let set1 = LineChartDataSet(entries: values, label: "USD")
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
	//		}
			let data = LineChartData(dataSets: datasets)

			chartView.data = data
		}
}
