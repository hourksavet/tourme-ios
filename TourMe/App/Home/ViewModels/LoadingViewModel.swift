//
//  LoadingViewModel.swift
//  TourMe
//
//  Created by Codex on 17/7/26.
//

import Combine
import Foundation

final class LoadingViewModel {

	enum Route {
		case naming
		case home
	}

	@Published private(set) var route: Route?

	private let dataManager: DataManager

	init(dataManager: DataManager = Const.dataManager) {
		self.dataManager = dataManager
	}

	func checkUserAccount() {
		let accounts = dataManager.fetchData(Account.self)
		route = accounts.isEmpty ? .naming : .home
	}
}
