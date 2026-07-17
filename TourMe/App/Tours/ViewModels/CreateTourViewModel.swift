//
//  CreateTourViewModel.swift
//  TourMe
//
//  Created by Codex on 17/7/26.
//

import CoreData
import Foundation

final class CreateTourViewModel {

	private let dataManager: DataManager
	private let notificationCenter: NotificationCenter

	init(dataManager: DataManager = Const.dataManager, notificationCenter: NotificationCenter = .default) {
		self.dataManager = dataManager
		self.notificationCenter = notificationCenter
	}

	func makePreviewTour(from data: CreateTourViewController.TourData) -> Tour {
		let context = dataManager.context
		let tour = Tour(context: context)
		configure(tour, with: data)
		tour.visitPlaces = makeVisitPlaces(for: data.places, in: context)
		return tour
	}

	@discardableResult
	func save(action: TourAction, tour: Tour?, data: CreateTourViewController.TourData) throws -> Tour {
		let context = dataManager.context
		let savedTour: Tour

		switch action {
			case .add:
				savedTour = Tour(context: context)
				configure(savedTour, with: data)
			case .edit:
				guard let tour else { throw NSError(domain: "TourMe.CreateTour", code: 1) }
				savedTour = tour
				configure(savedTour, with: data)
				if let visitPlaces = savedTour.visitPlaces?.compactMap({ $0 as? VisitPlace }) {
					for visitPlace in visitPlaces {
						context.delete(visitPlace)
					}
				}
			case .view:
				guard let tour else { throw NSError(domain: "TourMe.CreateTour", code: 2) }
				return tour
		}

		savedTour.visitPlaces = makeVisitPlaces(for: data.places, in: context)
		try context.save()
		notificationCenter.post(name: Utils.observerName(.addTour), object: nil, userInfo: [String.tour: savedTour])
		return savedTour
	}

	private func configure(_ tour: Tour, with data: CreateTourViewController.TourData) {
		if tour.id == nil {
			tour.id = UUID()
		}
		if tour.createdAt == nil {
			tour.createdAt = Date()
		}
		tour.name = data.name
		tour.vehicle = data.vehicle
		tour.banner = data.banner
		tour.isFavorite = data.isFavorite
	}

	private func makeVisitPlaces(for places: [Place], in context: NSManagedObjectContext) -> NSMutableOrderedSet {
		let orderedSet = NSMutableOrderedSet()
		for place in places {
			let visitPlace = VisitPlace(context: context)
			visitPlace.place = place
			orderedSet.add(visitPlace)
		}
		return orderedSet
	}
}
