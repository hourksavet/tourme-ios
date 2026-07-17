//
//  PlaceListViewModel.swift
//  TourMe
//
//  Created by Codex on 17/7/26.
//

import Combine
import CoreData
import Foundation

final class PlaceListViewModel {

	enum Source {
		case all
		case saved
		case visited
	}

	struct State {
		let places: [PlaceListModel]
		let isFavorite: Bool
	}

	enum Input {
		case viewDidLoad
		case viewWillAppear
		case toggleFavorite
		case placeChanged
	}

	@Published private(set) var state = State(places: [], isFavorite: false)

	private let source: Source
	private let dataManager: DataManager
	private let notificationCenter: NotificationCenter

	init(
		source: Source,
		dataManager: DataManager = Const.dataManager,
		notificationCenter: NotificationCenter = .default
	) {
		self.source = source
		self.dataManager = dataManager
		self.notificationCenter = notificationCenter
	}

	func send(_ input: Input) {
		switch input {
			case .viewDidLoad, .viewWillAppear, .placeChanged:
				reloadPlaces()
			case .toggleFavorite:
				state = State(places: state.places, isFavorite: !state.isFavorite)
				reloadPlaces()
		}
	}

	@discardableResult
	func delete(_ place: Place) -> Bool {
		let context = dataManager.context
		context.delete(place)

		do {
			try context.save()
			notificationCenter.post(name: Utils.observerName(.deletePlace), object: nil, userInfo: [String.place: place])
			return true
		} catch {
			print(error.localizedDescription)
			return false
		}
	}

	private func reloadPlaces() {
		let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
		let places = dataManager.fetchData(Place.self, predicate: predicate(), sortDescriptors: [sortDescriptor])
		state = State(places: places.map { PlaceListModel(place: $0) }, isFavorite: state.isFavorite)
	}

	private func predicate() -> NSPredicate? {
		switch (source, state.isFavorite) {
			case (.all, false):
				return nil
			case (.all, true):
				return NSPredicate(format: "isFavorite = true")
			case (.saved, false):
				return NSPredicate(format: "isUserAdd = true")
			case (.saved, true):
				return NSPredicate(format: "isFavorite = true AND isUserAdd = true")
			case (.visited, false):
				return NSPredicate(format: "visitCount > 0")
			case (.visited, true):
				return NSPredicate(format: "isFavorite = true AND visitCount > 0")
		}
	}
}
