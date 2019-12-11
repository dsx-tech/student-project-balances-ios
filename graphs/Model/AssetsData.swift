//
//  PieChartData.swift
//  graphs
//
//  Created by Danila Ferents on 25.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import Foundation

/// Name of asset with value
struct Asset: Codable {
	/// Name of the asset
	let asset: String

	/// Value of the asset
	let number: Double // maybe add quote for asset

	// if we need to change names, to conform json names use ...=""
	enum CodingKeys: String, CodingKey {
		case asset
		case number
	}
}

// delete this
struct AssetTimeValue: Codable {
	let asset: String
	let number: Double
	let date: Date
	let course: Double
}

// delete this
struct AssetsData: Codable {
	let assets: [Asset]

	func convertToStringAny() -> [Any] {
		var result: [Any] = []
		assets.forEach { (asset) in
			if let course = currencies[asset.asset] {
				result.append([asset.asset, asset.number * course])
			} else {
				debugPrint("No such course in dictionary")
			}
		}
		return result
	}
}

// delete this
struct AssetsTimeData: Codable {
	var assets: [AssetTimeValue]

	func convertToArray() -> [Any] {
		var time: [String] = []
		var numbers: [Double] = []
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		assets.forEach { (asset) in
			time.append(formatter.string(from: asset.date))
			numbers.append(asset.course * asset.number)
		}
		return [time, numbers]
	}
}


