//
//  OngoingTourViewModel.swift
//  TourMe
//
//  Created by Codex on 17/7/26.
//

import Combine
import CoreData
import Foundation

final class OngoingTourViewModel {

	struct State {
		let tour: Tour?
	}

	enum Input {
		case reload
		case ended
	}

	@Published private(set) var state = State(tour: nil)

	private let dataManager: DataManager
	private let notificationCenter: NotificationCenter

	init(dataManager: DataManager = Const.dataManager, notificationCenter: NotificationCenter = .default) {
		self.dataManager = dataManager
		self.notificationCenter = notificationCenter
	}

	func send(_ input: Input) {
		switch input {
			case .reload:
				state = State(tour: fetchOngoingTour())
			case .ended:
				state = State(tour: nil)
		}
	}

	func fetchOngoingTour() -> Tour? {
		let predicate = NSPredicate(format: "startDate != nil AND endDate == nil")
		let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: false)
		return dataManager.fetchData(Tour.self, predicate: predicate, sortDescriptors: [sortDescriptor]).first
	}

	func update(_ tour: Tour, places: [Place], vehicle: String) throws {
		let orderedSet = NSMutableOrderedSet()
		if let visitPlaces = tour.visitPlaces?.compactMap({ $0 as? VisitPlace }) {
			let context = dataManager.context
			let deleteList = visitPlaces.filter { visitPlace in
				places.first(where: { $0.id?.uuidString == visitPlace.place?.id?.uuidString }) == nil
			}

			for item in deleteList {
				context.delete(item)
			}

			for place in places {
				if let visitPlace = visitPlaces.first(where: { $0.place?.id?.uuidString == place.id?.uuidString }) {
					orderedSet.add(visitPlace)
				} else {
					let visitPlace = VisitPlace(context: context)
					visitPlace.place = place
					orderedSet.add(visitPlace)
				}
			}
		}

		tour.visitPlaces = orderedSet
		tour.vehicle = vehicle
		try dataManager.context.save()
	}

	func cancel(_ tour: Tour) throws {
		tour.startDate = nil
		try dataManager.context.save()
		notificationCenter.post(name: Utils.observerName(.endedTour), object: nil)
		state = State(tour: nil)
	}
}
