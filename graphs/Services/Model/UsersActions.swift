//
//  Trades.swift
//  graphs
//
//  Created by Danila Ferents on 30.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import Foundation

/// Trade format from DSX exchange
struct Trade: Codable {
	/// id of the trade in csv table
	let id: Int64
	/// time when trade was made: "yyyy-MM-dd'T'HH:mm:ss"
	let dateTime: Date
	/// trade instrument, example: USDBTC
	let instrument: String
	/// type of the trade: Buy/ Sell
	let tradeType: String
	/// traded currency value
	let tradedQuantity: Double
	/// traded currency name
	let tradedQuantityCurrency: String
	/// traded currency quote
	let tradedPrice: Double
	/// traded currency quote name
	let tradedPriceCurrency: String
	/// comission value
	let commission: Double
	/// comission currency name
	let commissionCurrency: String
	/// trade id from dsxexchange
	let tradeValueId: String
}

/// Transaction format from DSX exchange
struct Transaction: Codable {
	/// transaction id in csv table
	let id: UInt64
	/// transaction when trade was made: "yyyy-MM-dd'T'HH:mm:ss"
    var dateTime: Date
	/// transaction value
	let amount: Double
	/// transaction currency name
    let currency: String
	/// transaction id from DSX exchange
    let transactionValueId: String
	/// status: Failed | Complete | Rejected
    let transactionStatus: String
	/// type: Withdraw | Deposit
    let transactionType: String
	/// comission value
    let commission: Double
}

/// Quotes format from DSX exchange
struct QuotePeriod: Codable {
	///exchangeRate of instrument
	let exchangeRate: Double
	///timestamp in seconds
	let timestamp: Int64
}

struct Quote: Codable {
	let exchangeRate: Double
}

///Struct to get username and token from server
struct AuthResponse: Codable {
	let username: String
	let token: String
}

struct QuoteWithAsset {
	///exchangeRate of instrument
	let exchangeRate: Double
	///timestamp in seconds
	let timestamp: Int64
	let asset: String
}
