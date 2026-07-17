//
//  SavedToursViewModel.swift
//  TourMe
//
//  Created by Codex on 17/7/26.
//

import Combine
import CoreData
import Foundation

final class SavedToursViewModel {

	struct State {
		let tours: [Tour]
		let isFavorite: Bool

		var isEmpty: Bool {
			tours.isEmpty
		}
	}

	enum Input {
		case viewDidLoad
		case viewWillAppear
		case toggleFavorite
		case tourChanged
	}

	@Published private(set) var state = State(tours: [], isFavorite: false)

	private let dataManager: DataManager
	private let notificationCenter: NotificationCenter

	init(dataManager: DataManager = Const.dataManager, notificationCenter: NotificationCenter = .default) {
		self.dataManager = dataManager
		self.notificationCenter = notificationCenter
	}

	func send(_ input: Input) {
		switch input {
			case .viewDidLoad, .viewWillAppear, .tourChanged:
				reloadTours()
			case .toggleFavorite:
				state = State(tours: state.tours, isFavorite: !state.isFavorite)
				reloadTours()
		}
	}

	@discardableResult
	func delete(_ tour: Tour) -> Bool {
		let context = dataManager.context
		context.delete(tour)

		do {
			try context.save()
			notificationCenter.post(name: Utils.observerName(.deleteTour), object: nil, userInfo: [String.tour: tour])
			return true
		} catch {
			print(error.localizedDescription)
			return false
		}
	}

	private func reloadTours() {
		let predicate: NSPredicate
		if state.isFavorite {
			predicate = NSPredicate(format: "isFavorite = true AND startDate == nil")
		} else {
			predicate = NSPredicate(format: "startDate == nil")
		}

		let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
		let tours = dataManager.fetchData(Tour.self, predicate: predicate, sortDescriptors: [sortDescriptor])
		state = State(tours: tours, isFavorite: state.isFavorite)
	}
}
