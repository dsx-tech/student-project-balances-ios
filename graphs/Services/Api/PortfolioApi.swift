//
//  PortfolioApi.swift
//  graphs
//
//  Created by Danila Ferents on 12.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import Foundation
import Alamofire
import KeychainAccess

class PortfolioApi {
	// Make class Singleton
	static let sharedManager = PortfolioApi()
	var resultTradeFiles: Bool = true
	var resultTransactionFiles: Bool = true
	var resultTrade: Bool = true
	var resultTransaction: Bool = true

	private init() {
	}

	static fileprivate let serialQueue = DispatchQueue(label: "AuthApi", qos: .userInitiated, attributes: .concurrent)

	func getAllPortfolios(completion: @escaping (Bool, [Portfolio]?) -> Void) {

		guard let url = URL(string: Urls.portfolioUrl) else {
			print("Error in making url")
			return
		}

		let keychain = Keychain(service: "swagger")
		let token = try? keychain.get("token")

		guard let newtoken = token else { return }

		let headers: HTTPHeaders = [
			"Authorization": "Token_" + newtoken
		]

		AF.request(url, headers: headers).validate(statusCode: 200..<300).responseJSON(queue: PortfolioApi.self.serialQueue) { [weak self] (response) in

			guard let self = self else {
				print("No Api instance more")
				completion(false, nil)
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
				do {

					let portfolios = try decoder.decode([Portfolio].self, from: dataresponse)
					completion(true, portfolios)
				} catch {
					print(error.localizedDescription)
					debugPrint(error)
					completion(false, nil)
				}
			case .failure(let error):
				self.handleErrors(error: error)
				completion(false, nil)
			}
		}
	}

	func addPortfolio(portfolio: Portfolio, completion: @escaping (Bool, Portfolio?) -> Void) {

		guard let url = URL(string: Urls.portfolioUrl) else {
			print("Error in making url")
			return
		}

		let keychain = Keychain(service: "swagger")
		let token = try? keychain.get("token")

		guard let newtoken = token else { return }

		let headers: HTTPHeaders = [
			"Authorization": "Token_" + newtoken
		]

		let params: [String: Any] = [
			"id": portfolio.id,
			"name": portfolio.name
		]

		AF.request(url, method: .post,
				   parameters: params,
				   encoding: JSONEncoding.default,
				   headers: headers).validate(statusCode: 200..<300).responseJSON(queue: PortfolioApi.self.serialQueue) { [weak self] (response) in

					guard let self = self else {
						print("No Api instance more")
						completion(false, nil)
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
						do {

							let portfolio = try decoder.decode(Portfolio.self, from: dataresponse)
							completion(true, portfolio)
						} catch {
							print(error.localizedDescription)
							debugPrint(error)
							completion(false, nil)
						}
					case .failure(let error):
						self.handleErrors(error: error)
						completion(false, nil)
					}
		}
	}

	func updatePortfolio(id: Int, portfolio: Portfolio, completion: @escaping (Bool, Portfolio?) -> Void) {

		guard let url = URL(string: Urls.portfolioUrl + "/" + String(id)) else {
			print("Error in making url")
			return
		}

		let keychain = Keychain(service: "swagger")
		let token = try? keychain.get("token")

		guard let newtoken = token else { return }

		let headers: HTTPHeaders = [
			"Authorization": "Token_" + newtoken
		]

		let params: [String: Any] = [
			"id": id,
			"portfolioVO": [
				"id": portfolio.id,
				"name": portfolio.name
			]
		]

		AF.request(url,
				   method: .put,
				   parameters: params,
				   encoding: JSONEncoding.default,
				   headers: headers).validate(statusCode: 200..<300).responseJSON(queue: PortfolioApi.self.serialQueue) { [weak self] (response) in

					guard let self = self else {
						print("No Api instance more")
						completion(false, nil)
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
						do {

							let portfolio = try decoder.decode(Portfolio.self, from: dataresponse)
							completion(true, portfolio)
						} catch {
							print(error.localizedDescription)
							debugPrint(error)
							completion(false, nil)
						}
					case .failure(let error):
						self.handleErrors(error: error)
						completion(false, nil)
					}
		}
	}

	func deletePortfolio(id: Int, completion: @escaping (Bool) -> Void) {

		guard let url = URL(string: Urls.portfolioUrl + "/" + String(id)) else {
			print("Error in making url")
			return
		}

		let keychain = Keychain(service: "swagger")
		let token = try? keychain.get("token")

		guard let newtoken = token else { return }

		let headers: HTTPHeaders = [
			"Authorization": "Token_" + newtoken
		]

		let params: [String: Any] = [
			"id": id
		]

		AF.request(url,
				   method: .delete,
				   parameters: params,
				   encoding: JSONEncoding.default,
				   headers: headers).validate(statusCode: 200..<300).response(queue: PortfolioApi.self.serialQueue, completionHandler: { [weak self] (response) in

					guard let self = self else {
						print("No Api instance more")
						completion(false)
						return
					}

					switch response.result {
					case .success:
						completion(true)
					case .failure(let error):
						self.handleErrors(error: error)
						completion(false)
					}
				})
	}
}

// - MARK: Upload Trades And Transactions

extension PortfolioApi {

	func addTrade(id: Int, trade: Trade, completion: @escaping (Bool) -> Void) {

		guard let url = URL(string: Urls.tradesUrl + "?portfolioId=" + String(id)) else {
			print("Error in making url")
			return
		}

		let keychain = Keychain(service: "swagger")
		let token = try? keychain.get("token")

		guard let newtoken = token else { return }

		let headers: HTTPHeaders = [
			"Authorization": "Token_" + newtoken
		]

		let formatter = DateFormatter()

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		let params: [String: Any] = [
			"dateTime": formatter.string(from: trade.dateTime),
			"id": trade.id,
			"instrument": trade.instrument,
			"tradeType": trade.tradeType,
			"tradedQuantity": trade.tradedQuantity,
			"tradedQuantityCurrency": trade.tradedQuantityCurrency,
			"tradedPrice": trade.tradedPrice,
			"tradedPriceCurrency": trade.tradedPriceCurrency,
			"commission": trade.commission,
			"commissionCurrency": trade.commissionCurrency,
			"tradeValueId": trade.tradeValueId
		]

		AF.request(url,
				   method: .post,
				   parameters: params,
				   encoding: JSONEncoding.default,
				   headers: headers).validate(statusCode: 200..<300).responseJSON(queue: PortfolioApi.self.serialQueue) { [weak self] (response) in

			guard let self = self else {
				print("No Api instance more")
				completion(false)
				return
			}

			switch response.result {
			case .success:
				completion(true)
			case .failure(let error):
				self.handleErrors(error: error)
				completion(false)
			}
		}
	}

	func uploadTrades(csvFileFormat: String, id: Int, fileUrl: URL, completion: @escaping (Bool) -> Void) {

		guard let url = URL(string: Urls.tradesUrl + "/uploadFile" + "?csvFileFormat=" + csvFileFormat + "&portfolioId=" + String(id)) else {
			print("Error in making url")
			return
		}

		let keychain = Keychain(service: "swagger")
		let token = try? keychain.get("token")

		guard let newtoken = token else { return }

		let headers: HTTPHeaders = [
			"Authorization": "Token_" + newtoken
		]

		AF.upload(multipartFormData: { (multipartData) in
			multipartData.append(fileUrl, withName: "file")
		},
				  to: url,
				  method: .post,
				  headers: headers).validate(statusCode: 200..<300).response(queue: PortfolioApi.self.serialQueue, completionHandler: { [weak self] (response) in

			guard let self = self else {
				print("No Api instance more")
				completion(false)
				return
			}

			switch response.result {
			case .success:
				completion(true)
			case .failure(let error):
				self.handleErrors(error: error)
				completion(false)
			}
		})
	}

	func addTransaction(id: Int, transaction: Transaction, completion: @escaping (Bool) -> Void) {

		guard let url = URL(string: Urls.transactionsUrl + "?portfolioId=" + String(id)) else {
			print("Error in making url")
			return
		}

		let keychain = Keychain(service: "swagger")
		let token = try? keychain.get("token")

		guard let newtoken = token else { return }

		let headers: HTTPHeaders = [
			"Authorization": "Token_" + newtoken
		]

		let formatter = DateFormatter()

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		let params: [String: Any] = [
			"dateTime": formatter.string(from: transaction.dateTime),
			"id": transaction.id,
			"transactionType": transaction.transactionType,
			"currency": transaction.currency,
			"amount": transaction.amount,
			"commission": transaction.commission,
			"transactionStatus": transaction.transactionStatus,
			"transactionValueId": transaction.transactionValueId
		]

		AF.request(url,
				   method: .post,
				   parameters: params,
				   encoding: JSONEncoding.default,
				   headers: headers).validate(statusCode: 200..<300).responseJSON(queue: PortfolioApi.self.serialQueue) { [weak self] (response) in

			guard let self = self else {
				print("No Api instance more")
				completion(false)
				return
			}

			switch response.result {
			case .success:
				completion(true)
			case .failure(let error):
				self.handleErrors(error: error)
				completion(false)
			}
		}
	}

	func uploadTransactions(csvFileFormat: String, id: Int, fileUrl: URL, completion: @escaping (Bool) -> Void) {

		guard let url = URL(string: Urls.transactionsUrl + "/uploadFile" + "?csvFileFormat=" + csvFileFormat + "&portfolioId=" + String(id)) else {
			print("Error in making url")
			return
		}

		let keychain = Keychain(service: "swagger")
		let token = try? keychain.get("token")

		guard let newtoken = token else { return }

		let headers: HTTPHeaders = [
			"Authorization": "Token_" + newtoken
		]

		AF.upload(multipartFormData: { (multipartData) in
			multipartData.append(fileUrl, withName: "file")
		}, to: url,
		   method: .post,
		   headers: headers).validate(statusCode: 200..<300).response(queue: PortfolioApi.self.serialQueue, completionHandler: { [weak self] (response) in

			guard let self = self else {
				print("No Api instance more")
				completion(false)
				return
			}

			switch response.result {
			case .success:
				completion(true)
			case .failure(let error):
				self.handleErrors(error: error)
				completion(false)
			}
		})
	}

	func uploadTradesFiles(ids: [Int], csvFormat: String, fileUrl: URL, completion: @escaping (Bool) -> Void) {

		let apiGroup = DispatchGroup()

		self.resultTradeFiles = true

		ids.forEach { (id) in
			apiGroup.enter()

			uploadTrades(csvFileFormat: csvFormat, id: id, fileUrl: fileUrl) { [weak self] (result) in
				if !result {
					self?.resultTradeFiles = false
				}
				apiGroup.leave()
			}
		}

		apiGroup.notify(queue: PortfolioApi.self.serialQueue) { [weak self] in

			guard let self = self else {
				print("No Api instance more")
				return
			}
			completion(self.resultTradeFiles)
		}
	}

	func uploadTransactionsFiles(ids: [Int], csvFormat: String, fileUrl: URL, completion: @escaping (Bool) -> Void) {

		let apiGroup = DispatchGroup()

		self.resultTransactionFiles = true

		ids.forEach { (id) in
			apiGroup.enter()

			uploadTransactions(csvFileFormat: csvFormat, id: id, fileUrl: fileUrl) { [weak self] (result) in
				if !result {
					self?.resultTransactionFiles = false
				}
				apiGroup.leave()
			}
		}

		apiGroup.notify(queue: PortfolioApi.self.serialQueue) { [weak self] in

			guard let self = self else {
				print("No Api instance more")
				return
			}
			completion(self.resultTransactionFiles)
		}
	}

	func addTradeInPortfolios(ids: [Int], trade: Trade, completion: @escaping (Bool) -> Void) {

		let apiGroup = DispatchGroup()

		self.resultTrade = true

		ids.forEach { (id) in
			apiGroup.enter()

			addTrade(id: id, trade: trade) { [weak self] (result) in
				if !result {
					self?.resultTrade = false
				}
				apiGroup.leave()
			}
		}

		apiGroup.notify(queue: PortfolioApi.self.serialQueue) { [weak self] in

			guard let self = self else {
				print("No Api instance more")
				return
			}

			completion(self.resultTrade)
		}
	}

	func addTransactionInPortfolios(ids: [Int], transaction: Transaction, completion: @escaping (Bool) -> Void) {

		let apiGroup = DispatchGroup()

		self.resultTransaction = true

		ids.forEach { (id) in
			apiGroup.enter()

			addTransaction(id: id, transaction: transaction) { [weak self] (result) in
				if !result {
					self?.resultTransaction = false
				}
				apiGroup.leave()
			}
		}

		apiGroup.notify(queue: PortfolioApi.self.serialQueue) { [weak self] in

			guard let self = self else {
				print("No Api instance more")
				return
			}

			completion(self.resultTransaction)
		}
	}
}

// MARK: - Errors Handling

extension PortfolioApi {

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
