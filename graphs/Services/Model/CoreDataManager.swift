import Foundation
import UIKit
import CoreData

class CoreDataManager {
	static let sharedManager = CoreDataManager()

	private init() {

	}

	lazy var persistentContainer: NSPersistentContainer = {

		let container = NSPersistentContainer(name: "Data")

		container.loadPersistentStores(completionHandler: { (_, error) in

		if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		container.viewContext.automaticallyMergesChangesFromParent = true
		return container
	}()
}

// MARK: - QuotesProtocol

extension CoreDataManager {
	func syncQuotes(assets: [String], quotes: [String: [QuotePeriod]], start: Int64, end: Int64) {
		self.persistentContainer.performBackgroundTask { [weak self] (context) in
			guard let self = self else {
				return
			}

			let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QuoteCD")

			matchingRequest.predicate = NSPredicate(format: "asset in %@ AND timestamp <= @i AND timestamp >= @i", assets, start, end)

			var newquotes: [QuoteWithAsset] = []
			quotes.forEach { (key, value) in
				value.forEach { (quote) in
					newquotes.append(QuoteWithAsset(exchangeRate: quote.exchangeRate,
																timestamp: quote.timestamp,
																asset: key))
				}
			}

			do {
				let results = try context.fetch(matchingRequest)
				if let resultQuotes = results as? [QuoteCD] {
					resultQuotes.forEach { (object) in
						newquotes.removeAll { (quote) -> Bool in
							return quote.asset == object.asset && quote.exchangeRate == object.exchangeRate && quote.timestamp == object.timestamp
						}
					}
					newquotes.forEach { (quote) in
						let newquote = QuoteCD(context: context)

						newquote.asset = quote.asset
						newquote.exchangeRate = quote.exchangeRate
						newquote.timestamp = quote.timestamp
					}
					self.saveContext(context: context)
				}
			} catch {
				print("Error: \(error)\nCould not make request.")
			}
		}
	}

func readQuotes(assets: [String],
				start: Int64,
				end: Int64,
				completion: @escaping ([String: [QuotePeriod]]?) -> Void) {
		self.persistentContainer.performBackgroundTask { [weak self] (context) in
			guard let self = self else { return completion(nil) }

			let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QuoteCD")

			matchingRequest.predicate = NSPredicate(format: "asset in %@ AND timestamp <= @i AND timestamp >= @i", assets, start, end)

			do {
				let results = try context.fetch(matchingRequest)
				if let resultQuotes = results as? [QuoteCD] {
					if resultQuotes.count == assets.count * (NSCalendar.current.dateComponents([.day],
																							   from: Date(timeIntervalSince1970: Double(start)),
																							   to: Date(timeIntervalSince1970: Double(end))).day ?? 0) {
						var newquotes: [String: [QuotePeriod]] = [:]
						resultQuotes.forEach { (quote) in
							if newquotes[quote.asset] != nil {
								newquotes[quote.asset]?.append(QuotePeriod(exchangeRate: quote.exchangeRate, timestamp: quote.timestamp))
							} else {
								newquotes[quote.asset] = [QuotePeriod(exchangeRate: quote.exchangeRate, timestamp: quote.timestamp)]
							}
						}
						completion(newquotes)
					} else {
						completion(nil)
					}

					self.saveContext(context: context)
				}
			} catch {
				print("Error: \(error)\nCould not make request.")
			}
		}
	}
}

// MARK: - CoreDataManager

extension CoreDataManager {
	func entityForName(entityName: String, context: NSManagedObjectContext) -> NSEntityDescription {
		guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return NSEntityDescription() }
		return entity
	}

	func saveContext(context: NSManagedObjectContext) {
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				print("Error: \(error)\nCould not save Core Data context.")
			}
			context.reset()
		}
	}
}
