//
//  TradeApi.swift
//  graphs
//
//  Created by Danila Ferents on 30.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import Foundation
import Alamofire

struct Throwable<T: Decodable>: Decodable {
    let result: Result<T, Error>

    init(from decoder: Decoder) throws {
        do {
            let decoded = try T.init(from: decoder)
            result = .success(decoded)
        } catch let error {
            result = .failure(error)
        }
    }
}

class TradeApi {
	/**
	Get all Trades from backend
	- Author: Danila Ferents
	- Parameters:
		- url: Url to make response
		- completion: ([Trade]?) -> Void what to make with response
	*/
	func getAllTrades(url: String, completion: @escaping tradeResponseCompletion) {

		guard let url = URL(string: url) else {
			print("Error in URL making!")
			return} //make URL from string
		AF.request(url).responseJSON { (response) in
			//handle errors
			if let error = response.error {
				print(error.localizedDescription)
				completion(nil)
			}

			//get data from response and handle errors
			guard let dataresponse = response.data else {
				print("Error in pulling out data from response")
				return }

			//Initialise decoder
			let decoder = JSONDecoder()
			//Formater to convert string into date
			let formatter = DateFormatter()
			//String format in DSX exchange
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
			//Put formater into decoder
			decoder.dateDecodingStrategy = .formatted(formatter)
			do {
//				let data = try decoder.decode([Trade].self, from: data)
				//
				var throwables = try decoder.decode([Throwable<Trade>].self, from: dataresponse)
				var data = throwables.compactMap { try? $0.result.get() }
//				completion(data)
				formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
				decoder.dateDecodingStrategy = .formatted(formatter)
				throwables = try decoder.decode([Throwable<Trade>].self, from: dataresponse)
				let newdata = throwables.compactMap { try? $0.result.get() }
				for i in newdata {
					data.append(i)
				}
				completion(data)
			} catch {
				print(error.localizedDescription)
				debugPrint(error)
				//				completion(nil)
			}

		}
	}

	func getAllTransactions(url: String, completion: @escaping transactionsResponseCompletion) {

		guard let url = URL(string: url) else {
			print("Error in URL making!")
			return}
		AF.request(url).responseJSON { (response) in
			if let error = response.error {
				print(error.localizedDescription)
				completion(nil)
			}

			guard let dataresponse = response.data else {
				print("Error in pulling out data from response")
				return }
			let decoder = JSONDecoder()
			let formatter = DateFormatter()
			//			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
			decoder.dateDecodingStrategy = .formatted(formatter)
			do {
				var throwables = try decoder.decode([Throwable<Transaction>].self, from: dataresponse)
				var data = throwables.compactMap { try? $0.result.get() }
				formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
				decoder.dateDecodingStrategy = .formatted(formatter)
				throwables = try decoder.decode([Throwable<Transaction>].self, from: dataresponse)
				let newdata = throwables.compactMap { try? $0.result.get() }
				for  i in newdata {
					data.append(i)
				}
				completion(data)
			} catch {
				print(error.localizedDescription)
				debugPrint(error)
				//				completion(nil)
			}
		}
	}
}
