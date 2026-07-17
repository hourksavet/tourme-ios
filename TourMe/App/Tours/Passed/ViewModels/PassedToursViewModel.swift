//
//  PassedToursViewModel.swift
//  TourMe
//
//  Created by Codex on 17/7/26.
//

import Combine
import Foundation

final class PassedToursViewModel {

	struct State {
		let tours: [Tour]

		var isEmpty: Bool {
			tours.isEmpty
		}
	}

	enum Input {
		case viewDidLoad
		case viewWillAppear
		case endedTour
	}

	@Published private(set) var state = State(tours: [])

	private let dataManager: DataManager

	init(dataManager: DataManager = Const.dataManager) {
		self.dataManager = dataManager
	}

	func send(_ input: Input) {
		switch input {
			case .viewDidLoad, .viewWillAppear, .endedTour:
				reloadTours()
		}
	}

	private func reloadTours() {
		let settings = NSPredicate(format: "endDate != nil")
		let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: false)
		let tours = dataManager.fetchData(Tour.self, predicate: settings, sortDescriptors: [sortDescriptor])
		state = State(tours: tours)
	}
}
