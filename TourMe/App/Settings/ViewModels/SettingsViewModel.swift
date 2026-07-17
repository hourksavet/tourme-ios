//
//  SettingsViewModel.swift
//  TourMe
//
//  Created by Codex on 17/7/26.
//

import Combine
import Foundation

final class SettingsViewModel {

	struct State {
		let account: Account?
	}

	enum Input {
		case viewDidLoad
		case accountUpdated(Account)
	}

	@Published private(set) var state = State(account: nil)

	private let dataManager: DataManager

	init(dataManager: DataManager = Const.dataManager) {
		self.dataManager = dataManager
	}

	func send(_ input: Input) {
		switch input {
			case .viewDidLoad:
				loadAccount()
			case .accountUpdated(let account):
				state = State(account: account)
		}
	}

	private func loadAccount() {
		state = State(account: dataManager.fetchData(Account.self).first)
	}
}
