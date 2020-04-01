//
//  AuthApi.swift
//  graphs
//
//  Created by Danila Ferents on 24.03.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import Foundation
import Alamofire

class AuthApi {
	func authLogin(url: String, username: String, password: String, completion: @escaping AuthResponseCompletion) {
		guard let url = URL(string: url) else {
			print("Error in making url")
			return
		}
		let params: [String: Any] = [
			"password": password,
			"username": username
		]
		AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).validate().responseJSON { (response) in
			switch response.result {
			case .success(let value):
				//get data from response
				guard let data = response.data else {
					print("Error in pulling out data from response")
					completion(nil)
					return }

				let decoder = JSONDecoder()

				do {
					let login = try decoder.decode(AuthResponse.self, from: data)
					completion(login)
				} catch {
					print(error.localizedDescription)
					debugPrint(error)
					completion(nil)
				}
			case .failure(let error):
				print(error.localizedDescription)
				debugPrint(error)
				completion(nil)
			}
		}
	}

	func createUser(url: String, email: String, password: String, username: String, completion: @escaping AuthResponseCompletion) {
		guard let url = URL(string: url) else {
			print("Error in making url")
			return
		}
		let params = [
			"email": email,
			"password": password,
			"username": username
		]
		AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).validate().responseJSON { (response) in
			switch response.result {
			case .success(let value):
				//get data from response
				guard let data = response.data else {
					print("Error in pulling out data from response")
					completion(nil)
					return }

				let decoder = JSONDecoder()

				do {
					let login = try decoder.decode(AuthResponse.self, from: data)
					completion(login)
				} catch {
					print(error.localizedDescription)
					debugPrint(error)
					completion(nil)
				}
			case .failure(let error):
				print(error.localizedDescription)
				debugPrint(error)
				completion(nil)
			}
		}
	}
}
