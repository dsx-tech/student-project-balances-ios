//
//  AuthApi.swift
//  graphs
//
//  Created by Danila Ferents on 24.03.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

///Class for Authentification Api
class AuthApi {

	// Make class Singleton
	static let sharedManager = AuthApi()

	private init() {
	}

	static fileprivate let serialQueue = DispatchQueue(label: "AuthApi", qos: .userInitiated, attributes: .concurrent)

	/**
	Login to backend
	- Author: Danila Ferents
	- Parameters:
		- username: name of user to login
		- password: password of user to login
		- completion: (AuthResponseCompletion) -> Void what to make with response
	*/

	func authLogin(username: String, password: String, completion: @escaping AuthResponseCompletion) {
		
		guard let url = URL(string: Urls.loginUrl) else {
			print("Error in making url")
			return
		}

		let params: [String: Any] = [
			"password": password,
			"username": username
		]

		AF.request(url,
				   method: .post,
				   parameters: params,
				   encoding: JSONEncoding.default).validate().responseJSON(queue: AuthApi.self.serialQueue) { [weak self ] (response) in

			guard let self = self else {
				print("No Api instance more")
				completion(nil, false)
				return
			}

			switch response.result {
			case .success:
				//get data from response
				guard let data = response.data else {
					print("Error in pulling out data from response")
					completion(nil, false)
					return }

				let decoder = JSONDecoder()

				do {
					let login = try decoder.decode(AuthResponse.self, from: data)
					completion(login, true)
				} catch {
					print(error.localizedDescription)
					debugPrint(error)
					completion(nil, false)
				}
			case .failure(let error):
				self.handleErrors(error: error, completion: completion)
				completion(nil, false)
			}
		}
	}

	/**
	Register in system
	- Author: Danila Ferents
	- Parameters:
		- email: emil of user
		- username: name of user to register
		- password: password of user toregister
		- completion: (AuthResponseCompletion) -> Void what to make with response
	*/

	func createUser(email: String, password: String, username: String, completion: @escaping AuthResponseCompletion) {

		guard let url = URL(string: Urls.registerUrl) else {
			print("Error in making url")
			return
		}

		let params = [
			"email": email,
			"password": password,
			"username": username
		]

		AF.request(url,
				   method: .post,
				   parameters: params,
				   encoding: JSONEncoding.default).validate().responseJSON(queue: AuthApi.self.serialQueue) { [weak self] (response) in

			guard let self = self else {
				print("No Api instance more")
				completion(nil, false)
				return
			}

			switch response.result {
			case .success:
				//get data from response
				guard let data = response.data else {
					print("Error in pulling out data from response")
					completion(nil, false)
					return }

				let decoder = JSONDecoder()

				do {
					let login = try decoder.decode(AuthResponse.self, from: data)
					completion(login, true)
				} catch {
					print(error.localizedDescription)
					debugPrint(error)
					completion(nil, false)
				}
			case .failure(let error):
				self.handleErrors(error: error, completion: completion)
			}
		}
	}

	/**
	func to handle Network errors
	- Author: Danila Ferents
	- Parameters:
		- error: error to handle
		- completion: (AuthResponseCompletion) -> Void what to make with response
	*/

	func handleErrors(error: Error, completion: @escaping AuthResponseCompletion) {

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

		completion(nil, false)
	}

}
