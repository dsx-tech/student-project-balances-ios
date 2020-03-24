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
	func authLogin(url: String, email: String, password: String, username: String, completion: @escaping AuthLoginResponseCompletion) {
		guard let url = URL(string: url) else { return }
		let params: [String: Any] = [
			"email": email,
			"password": password,
			"username": username
		]
		AF.request(url, method: .post, parameters: params).responseJSON { (response) in
			//handle errors
			if let error = response.error {
				print(error.localizedDescription)
				completion(nil)
			}

			//get data from response
			guard let data = response.data else {
				print("Error in pulling out data from response")
				completion(nil)
				return }

			let decoder = JSONDecoder()

			do {
				let login = try decoder.decode(LoginResponse.self, from: data)
				completion(login)
			} catch {
				print(error.localizedDescription)
				debugPrint(error)
				completion(nil)
			}
		}
	}
}
