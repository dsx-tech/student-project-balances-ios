//
//  Constants.swift
//  graphs
//
//  Created by Danila Ferents on 26.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import Foundation
import UIKit

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
///response format for api escaping request
/// - Returns: [Quote]?
typealias quotesResponseCompletion = ([Quote]?) -> Void

enum durationQuotes: Int {
	case month
	case threemonths
	case sixmonths
	case year

	static let allvalues = ["month", "3 months", "6 month", "1 year"]
}

struct Urls {
	static let quotesurl = "http://3.248.170.197:8888/bcv/quotes/bars/"
}

struct Identifiers {
    static let quoteCell = "quoteCell"
}

struct Segues {
	static let toAdd = "toStart"
	static let toGraph = "toGraph"
}

struct AppColors {
    static let Green = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    static let Red = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
	static let Default = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
	static let Blue = #colorLiteral(red: 0.2914361954, green: 0.3395442367, blue: 0.4364506006, alpha: 1)
}

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

let allcurrencies = [
	"usd",
	"bsv",
	"bch",
	"eurs",
	"eos",
	"btc",
	"xrp",
	"btg",
	"gbp",
	"eth",
	"ltc",
	"try",
	"rub",
	"eur",
	"usdt"
]

let instruments = [
  "eth-usd",
  "ltc-usdt",
  "bch-btc",
  "eos-usd",
  "eur-usd",
  "btg-usd",
  "btc-rub",
  "eth-eurs",
  "eth-usdt",
  "usdt-eur",
  "eth-gbp",
  "bsv-usd",
  "ltc-btc",
  "btc-eurs",
  "usd-try",
  "btg-eur",
  "bsv-eth",
  "btc-eur",
  "eos-btc",
  "xrp-usd",
  "bch-eur",
  "ltc-eur",
  "eurs-usd",
  "btc-try",
  "ltc-eurs",
  "bsv-btc",
  "ltc-try",
  "bch-eurs",
  "gbp-usd",
  "btc-gbp",
  "eur-try",
  "btg-btc",
  "eos-eur",
  "usd-rub",
  "usdt-usd",
  "eth-btc",
  "bsv-eur",
  "eth-try",
  "eos-eth",
  "bch-usdt",
  "xrp-eur",
  "eth-eur",
  "bch-usd",
  "bch-gbp",
  "btg-gbp",
  "ltc-gbp",
  "btc-usd",
  "xrp-btc",
  "eurs-eur",
  "ltc-usd",
  "btc-usdt"
]
