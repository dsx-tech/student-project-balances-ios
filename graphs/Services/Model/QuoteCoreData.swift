//
//  QuoteCoreData.swift
//  graphs
//
//  Created by Danila Ferents on 18.05.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import Foundation
import CoreData

@objc(Quote)
public class QuoteCD: NSManagedObject {
	convenience init(coreData: CoreDataManager, context: NSManagedObjectContext) {
		self.init(entity: coreData.entityForName(entityName: "QuoteCD", context: context),
		insertInto: context)
	}

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuoteCD> {
        return NSFetchRequest<QuoteCD>(entityName: "QuoteCD")
    }

    @NSManaged public var exchangeRate: Double
    @NSManaged public var timestamp: Int64
    @NSManaged public var asset: String
	@NSManaged public var duration: String

}
