//
//  Constants.swift
//  graphs
//
//  Created by Danila Ferents on 26.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import Foundation

///response format for api escaping request
/// - Returns: AssetsData?
typealias assetsResponseCompletion = (AssetsData?) -> Void
///response format for api escaping request
/// - Returns: AssetsTimeData?
typealias assetsTimeResponseCompletion = (AssetsTimeData?) -> Void
///response format for api escaping request
/// - Returns: [Trade]?
typealias tradeResponseCompletion = ([Trade]?) -> Void
///response format for api escaping request
/// - Returns: [Transaction]?
typealias transactionsResponseCompletion = ([Transaction]?) -> Void

let currencies : [String: Double] = ["$" : 1, "€" : 1.3]
let currencies1: [String: Double] = ["BTC": 7496.58,
	"ETH": 150.2,
	"BSV": 96.59,
	"EOS": 2.744,
	"EUR": 1.11,
	"TRY": 0.17,
	"EURS": 1.10,
	"BTG": 5.97,
	"BCH": 213.3,
	"LTC": 45.56,
	"GBP": 1.32,
	"USDT": 1.0003,
	"RUB": 0.016,
	"USD": 1.0
]
