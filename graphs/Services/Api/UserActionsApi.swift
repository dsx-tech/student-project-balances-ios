//
//  TradeApi.swift
//  graphs
//
//  Created by Danila Ferents on 30.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import Foundation
import Alamofire
import KeychainAccess

struct Throwable<T: Decodable>: Decodable {
	let result: Result<T, Error>

	init(from decoder: Decoder) throws {
		do {
			let decoded = try T(from: decoder)
			result = .success(decoded)
		} catch let error {
			result = .failure(error)
		}
	}
}

// MARK: - Functions to get Trades, Transactions and Quotes

class TradeApi {

	static fileprivate let concurrentQueue = DispatchQueue(label: "TradeApi", qos: .userInitiated, attributes: .concurrent)

	var trades: [Trade]!
	var transactions: [Transaction]!

	/**
	Get all Trades from backend
	- Author: Danila Ferents
	- Parameters:
	- url: Url to make response
	- completion: ([Trade]?) -> Void what to make with response
	*/
	func getAllTrades(url: String, completion: @escaping TradeResponseCompletion) {

		guard let url = URL(string: url) else {
			print("Error in URL making!")
			completion(nil)
			return} //make URL from string

		let keychain = Keychain(service: "swagger")
		let token = try? keychain.get("token")

		guard let newtoken = token else { return }

		let headers: HTTPHeaders = [
			"Authorization": "Token_" + newtoken
		]

		AF.request(url, headers: headers).validate().responseJSON(queue: TradeApi.self.concurrentQueue) { [weak self] (response) in

			guard let self = self else {
				print("No Api instance more")
				completion(nil)
				return
			}

			switch response.result {
			case .success:
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
					completion(nil)
				}
			case .failure(let error):
				self.handleErrors(error: error)
				completion(nil)
			}

		}
	}

	/**
	Get all transactions from backend
	- Parameters:
	- url: Url to make response
	- completion: ([Transaction]?) -> Void what to make with response
	*/
	func getAllTransactions(url: String, completion: @escaping TransactionsResponseCompletion) {

		guard let url = URL(string: url) else {
			print("Error in URL making!")
			return} //make url from string

		let keychain = Keychain(service: "swagger")
		let token = try? keychain.get("token")

		guard let newtoken = token else { return }

		let headers: HTTPHeaders = [
			"Authorization": "Token_" + newtoken
		]

		AF.request(url, headers: headers).validate().responseJSON(queue: TradeApi.self.concurrentQueue) { [weak self] (response) in

			guard let self = self else {
				print("No Api instance more")
				completion(nil)
				return
			}
			switch response.result {
			case .success:

				//handle errors
				if let error = response.error {
					print(error.localizedDescription)
					completion(nil)
				}

				//getting data from response
				guard let dataresponse = response.data else {
					print("Error in pulling out data from response")
					return }

				let decoder = JSONDecoder()
				let formatter = DateFormatter()
				//			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
				formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
				decoder.dateDecodingStrategy = .formatted(formatter)
				do {
					//this is made to avoid mistakes in formatting different dates
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
					completion(nil)
				}
			case .failure(let error):
				self.handleErrors(error: error)
			}
		}
	}
	/**
	Get all quotes from backend
	- Parameters:
	- url: Url to make response
	- instrument: ex: btc-usd
	- startTime: Date from which to count
	- endTime: Date up to witch to count
	- completion: ([Quote]?) -> Void what to make with response
	*/
	func getQuotesinPeriod(url: String, instrument: String, startTime: Date, endTime: Date, completion: @escaping QuotesResponseCompletion) {

		let fullurl = url + instrument + "/" + String(Int(startTime.timeIntervalSince1970)) + "/" + String(Int(endTime.timeIntervalSince1970))

		guard let url = URL(string: fullurl) else {
			print("Error in url making!")
			completion(nil)
			return } //make url from string

		AF.request(url).responseJSON { [weak self] (response) in

			guard let self = self else {
				print("No Api instance more")
				completion(nil)
				return
			}

			//handle errors
			if let error = response.error {
				print(error.localizedDescription)
				completion(nil)
			}

			//get data from response
			guard let data = response.data else {
				print("Error in pulling out data from response")
				return
			}

			let decoder = JSONDecoder()

			do {
				let quotes = try decoder.decode([Quote].self, from: data)
				completion(quotes)

				//				var throwables = try decoder.decode([Throwable<Quote>].self, from: data)
				//				var data2 = throwables.compactMap { try? $0.result.get() }
				//
				//				var throwables2 = try decoder.decode([Throwable<QuoteI>].self, from: data)
				//
				//				let newdata = throwables.compactMap { try? $0.result.get() }
				//
				//				for  i in newdata {
				//					let newdata = Quote(exchangeRate: Double(i.exchangeRate), timestamp: i.timestamp)
				//					data2.append(newdata)
				//				}
				//				completion(data2)
			} catch {
				print(error.localizedDescription)
				debugPrint(error)
				completion(nil)
			}
		}
	}
}

extension TradeApi {

	func getAllTradesAndTransactions(id: String, completion: @escaping  ([Trade?], [Transaction?]) -> Void) {

		//to get trades and transactions concurrently and return in one completion
		let apiGroup = DispatchGroup()
		let urltrades = "http://3.248.170.197:9999/bcv/portfolios" + id + "/trades"
		let urltransactions = "http://3.248.170.197:9999/bcv/portfolios" + id + "/transactions"
		
		apiGroup.enter()
		getAllTrades(url: urltrades) { [weak self] (trades) in

			guard let self = self else {
				print("No Api instance more")
				return
			}
			self.trades = trades
			apiGroup.leave()
		}

		apiGroup.enter()

		getAllTransactions(url: urltransactions) { [weak self] (transactions) in

			guard let self = self else {
				print("No Api instance more")
				return
			}
			self.transactions = transactions
			apiGroup.leave()
		}

		apiGroup.notify(queue: TradeApi.concurrentQueue) { [weak self] in

			guard let self = self else {
				print("No Api instance more")
				return
			}

			completion(self.trades, self.transactions)
		}
	}

}

// MARK: - Errors Handling

extension TradeApi {

	func handleErrors(error: Error) {

		if let error = error as? AFError {
			switch error {
			case .invalidURL(let url):
				print("Invalid URL: \(url) - \(error.localizedDescription)")
			case .parameterEncodingFailed(let reason):
				print("Parameter encoding failed: \(error.localizedDescription)")
				print("Failure Reason: \(reason)")
			case .multipartEncodingFailed(let reason):
				print("Multipart encoding failed: \(error.localizedDescription)")
				print("Failure Reason: \(reason)")
			case .responseValidationFailed(let reason):
				print("Response validation failed: \(error.localizedDescription)")
				print("Failure Reason: \(reason)")

				switch reason {
				case .dataFileNil, .dataFileReadFailed:
					print("Downloaded file could not be read")
				case .missingContentType(let acceptableContentTypes):
					print("Content Type Missing: \(acceptableContentTypes)")
				case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
					print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
				case .unacceptableStatusCode(let code):
					print("Response status code was unacceptable: \(code)")
				case .customValidationFailed(error: let error):
					print("Response status code was unacceptable: \(error)")
				}
			case .responseSerializationFailed(let reason):
				print("Response serialization failed: \(error.localizedDescription)")
				print("Failure Reason: \(reason)")
			case .createUploadableFailed(error: let error):
				print("Create Uploadable Failed \(error.localizedDescription)")
			case .createURLRequestFailed(error: let error):
				print("Create URLRequest Failed \(error.localizedDescription)")
			case .urlRequestValidationFailed(reason: let reason):
				print("Url RequestValidation Failed, reason: \(reason)")
			default:
				print("Other errors!")
			}

			print("Underlying error: \(String(describing: error.underlyingError))")
		} else if let error = error as? URLError {
			print("URLError occurred: \(error)")
		} else {
			print("Unknown error: \(error)")
		}
	}
}
