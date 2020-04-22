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

		AF.request(url, headers: headers).validate(statusCode: 200..<500).responseJSON(queue: PortfolioApi.self.serialQueue) { [weak self] (response) in

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
				   headers: headers).validate(statusCode: 200..<500).responseJSON { [weak self] (response) in

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
				   headers: headers).validate(statusCode: 200..<500).responseJSON { [weak self] (response) in

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
				   headers: headers).validate(statusCode: 200..<500).response(completionHandler: { [weak self] (response) in

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

	func uploadTrades(id: Int, fileUrl: URL, completion: @escaping (Bool) -> Void) {

		guard let url = URL(string: Urls.portfolioUrl + "/" + String(id) + "trades/upload") else {
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
			guard let idData = id.description.data(using: .utf8) else {
				completion(false)
				return
			}
			multipartData.append(idData, withName: "id")
		}, to: url, method: .post, headers: headers).validate(statusCode: 200..<500).responseJSON(completionHandler: { [weak self] (response) in

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

	func uploadTransactions(id: Int, fileUrl: URL, completion: @escaping (Bool) -> Void) {

		guard let url = URL(string: Urls.portfolioUrl + "/" + String(id) + "transactions/upload") else {
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
			guard let idData = id.description.data(using: .utf8) else {
				completion(false)
				return
			}
			multipartData.append(idData, withName: "id")
		}, to: url, method: .post, headers: headers).validate(statusCode: 200..<600).responseJSON(completionHandler: { [weak self] (response) in

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
