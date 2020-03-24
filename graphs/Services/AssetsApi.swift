//
//  PieChartApi.swift
//  graphs
//
//  Created by Danila Ferents on 26.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import Foundation
import Alamofire

//delete this
class AssetsApi {
	func getDataForPortfolioPieChart(url: String, completion: @escaping AssetsResponseCompletion) {
		guard let url = URL(string: url) else {
			print("Error in URL making!")
			return}
		AF.request(url).responseJSON { (response) in
			if let error = response.error {
				debugPrint(error.localizedDescription)
				completion(nil)
				return
			}
			guard let data = response.data else {
				print("Error in pulling out data from response")
				return }
			let jsonDecoder = JSONDecoder()

			do {
				let assets = try jsonDecoder.decode(AssetsData.self, from: data)
				completion(assets)
			} catch {
				debugPrint(error.localizedDescription)
				completion(nil)
			}
		}
	}
}

class AssetsValueApi {
	func getDataForTimeAssetChart(url: String, completion: @escaping AssetsTimeResponseCompletion) {
			guard let url = URL(string: url) else {
			print("Error in URL making!")
				return}
			AF.request(url).responseJSON { (response) in
				if let error = response.error {
					debugPrint(error.localizedDescription)
					completion(nil)
					return
				}
				guard let data = response.data else {
				print("Error in pulling out data from response")
					return }
				let jsonDecoder = JSONDecoder()

				do {
					let assets = try jsonDecoder.decode(AssetsTimeData.self, from: data)
					completion(assets)
				} catch {
					debugPrint(error.localizedDescription)
					completion(nil)
				}
			}
		}
	}
