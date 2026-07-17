//
//  PlaceDetailsViewModel.swift
//  TourMe
//
//  Created by Codex on 17/7/26.
//

import Foundation

final class PlaceDetailsViewModel {

	private let dataManager: DataManager
	private let notificationCenter: NotificationCenter

	init(dataManager: DataManager = Const.dataManager, notificationCenter: NotificationCenter = .default) {
		self.dataManager = dataManager
		self.notificationCenter = notificationCenter
	}

	@discardableResult
	func save(action: PlaceAction, place: Place?, data: PlaceDetailsViewController.PlaceData) throws -> Place {
		switch action {
			case .edit:
				guard let place else { throw NSError(domain: "TourMe.PlaceDetails", code: 1) }
				place.thumb = data.thumnail
				place.name = data.name
				place.lat = data.lat
				place.lng = data.lng
				place.note = data.note
				place.isFavorite = data.isFavorite
				try dataManager.context.save()
				notificationCenter.post(name: Utils.observerName(.addPlace), object: nil, userInfo: [String.place: place])
				return place
			case .add:
				let context = dataManager.context
				let place = Place(context: context)
				place.isFavorite = data.isFavorite
				place.isUserAdd = true
				place.stars = 0
				place.id = UUID()
				place.date = Date()
				place.thumb = data.thumnail
				place.name = data.name
				place.lat = data.lat
				place.lng = data.lng
				place.note = data.note
				try context.save()
				notificationCenter.post(name: Utils.observerName(.addPlace), object: nil, userInfo: [String.place: place])
				return place
			case .view:
				guard let place else { throw NSError(domain: "TourMe.PlaceDetails", code: 2) }
				return place
		}
	}

	func delete(_ place: Place) throws {
		let context = dataManager.context
		context.delete(place)
		try context.save()
		notificationCenter.post(name: Utils.observerName(.deletePlace), object: nil, userInfo: [String.place: place])
	}
}
