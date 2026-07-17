//
//  BaseTourMeViewModel.swift
//  TourMe
//
//  Created by Codex on 17/7/26.
//

import Combine
import CoreData
import Foundation

final class BaseTourMeViewModel {

	struct State {
		let ongoingTour: Tour?
	}

	enum Input {
		case viewDidLoad
		case tourStarted
		case tourEnded
	}

	@Published private(set) var state = State(ongoingTour: nil)

	private let dataManager: DataManager

	init(dataManager: DataManager = Const.dataManager) {
		self.dataManager = dataManager
	}

	func send(_ input: Input) {
		switch input {
			case .viewDidLoad, .tourStarted:
				state = State(ongoingTour: fetchOngoingTour())
			case .tourEnded:
				state = State(ongoingTour: nil)
		}
	}

	private func fetchOngoingTour() -> Tour? {
		let predicate = NSPredicate(format: "startDate != nil AND endDate == nil")
		let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: false)
		return dataManager.fetchData(Tour.self, predicate: predicate, sortDescriptors: [sortDescriptor]).first
	}
}
