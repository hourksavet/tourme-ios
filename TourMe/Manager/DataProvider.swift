//
//  DataProvider.swift
//  TourMe
//
//  Created by Savet on 8/7/25.
//

import CoreData

class DataManager {
	
	private let container: NSPersistentContainer

	var context: NSManagedObjectContext {
		container.viewContext
	}
	
	init() {
		container = NSPersistentContainer(name: "Database") // Match .xcdatamodeld filename
		container.loadPersistentStores { (_, error) in
			if let error = error {
				fatalError("Unresolved error: \(error)")
			}
		}
	}
	
	func fetchData<T: NSManagedObject>(_ type: T.Type,
										   predicate: NSPredicate? = nil,
										   sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
		let request = T.fetchRequest()
		request.predicate = predicate
		request.sortDescriptors = sortDescriptors
		
		do {
			if let result = try container.viewContext.fetch(request) as? [T] {
				return result
			}
		} catch {
			print("Fetch error: \(error)")
		}
		return []
	}
	
	func saveOrUpdate<T: NSManagedObject>(type: T.Type, predicate: NSPredicate?, configure: (T) -> Void) throws {
		let request = T.fetchRequest()
		request.predicate = predicate
		request.fetchLimit = 1
		
		if let existing = try container.viewContext.fetch(request).first as? T {
			// Update
			configure(existing)
		} else {
			// Create
			let newObject = T(context: container.viewContext)
			configure(newObject)
		}
		try container.viewContext.save()
	}
}
