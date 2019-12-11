//
//  UrlSessionTests.swift
//  graphsTests
//
//  Created by Danila Ferents on 02.12.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import XCTest
@testable import graphs

class UrlSessionTests: XCTestCase {

	var sessionUnderTests: URLSession!

    override func setUp() {
		super.setUp()
		sessionUnderTests = URLSession(configuration: URLSessionConfiguration.default)
    }

    override func tearDown() {
		sessionUnderTests = nil
    }

    func testValidTradesCalltoServerGetsHTTPStatusCode200() {
		//given
		guard let url = URL(string: "http://localhost:9999/bcv/trades") else { XCTFail("Error in making URL!"); return}
		let promise = expectation(description: "Completion handler invoked")
		var statusCode: Int?
		var responseError: Error?

		//when
		let dataTask = sessionUnderTests.dataTask(with: url) { (data, response, error) in
			statusCode = (response as? HTTPURLResponse)?.statusCode
			responseError = error

			promise.fulfill()
		}
		dataTask.resume()

		waitForExpectations(timeout: 5, handler: nil)
		XCTAssertNil(responseError)
		XCTAssertEqual(statusCode, 200)
    }

	func testValidTransactionCalltoServerGetsHTTPStatusCode200() {
		//given
		let promise = expectation(description: "Completion handler invoked")
		guard let url = URL(string: "http://localhost:9999/bcv/transactions") else { XCTFail("Error in making URL!"); return}
		var statusCode: Int?
		var responseError: Error?

		//when
		let dataTask = sessionUnderTests.dataTask(with: url) { (data, response, error) in
			statusCode = (response as? HTTPURLResponse)?.statusCode
			responseError = error

			promise.fulfill()
		}
		dataTask.resume()

		waitForExpectations(timeout: 5, handler: nil)
		XCTAssertNil(responseError)
		XCTAssertEqual(statusCode, 200)

	}
}
