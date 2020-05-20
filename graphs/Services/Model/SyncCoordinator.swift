//
//  SyncCoordinator.swift
//  graphs
//
//  Created by Danila Ferents on 20.05.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import Foundation

class SyncCoordinator {
	var quoteApi = TradeApi()
	func getAndSyncQuotesInPeriod(assets: [String], start: Date, end: Date, completion: @escaping ([String: [QuotePeriod]]?) -> Void) {
		CoreDataManager.sharedManager.readQuotes(assets: assets,
												 start: Int64(start.timeIntervalSince1970),
												 end: Int64(end.timeIntervalSince1970),
												 completion: { (quotes) in
			if let unwrappedquotes = quotes {
				completion(unwrappedquotes)
			} else {
				self.quoteApi.getQuotesinPeriod(instruments: assets,
												startTime: start,
												endTime: end) { (quotes) in
					completion(quotes)
					if let unwrappedquotes = quotes {
						CoreDataManager.sharedManager.syncQuotes(assets: assets,
																 quotes: unwrappedquotes,
																 start: Int64(start.timeIntervalSince1970),
																 end: Int64(end.timeIntervalSince1970))
					}
				}
			}
		})
	}
}
