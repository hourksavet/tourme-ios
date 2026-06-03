//
//  SettingsViewController.swift
//  TourMe
//
//  Created by Savet on 3/7/25.
//

import UIKit

class SettingsViewController: UIViewController {

	private var account: Account!
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.register(DefaultViewCell.self)
		tableView.register(SettingViewCell.self)
		tableView.register(ProfileTableViewCell.self)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	override func loadView() {
		super.loadView()
		view.addSubview(tableView)
		
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = "settings".localized()
		navigationController?.navigationBar.tintColor = .primary
		navigationController?.navigationBar.prefersLargeTitles = true
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.largeTitleTextAttributes = [
			.font: UIFont.defaultBold(size: 30),
			.foregroundColor: UIColor.primary
		]
		appearance.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor:UIColor.primary,
			NSAttributedString.Key.font: UIFont.defaultMedium(size: UIFont.medium)
		]
		navigationItem.standardAppearance = appearance
		navigationItem.rightBarButtonItem?.tintColor = .black
		view.backgroundColor = .screenBackground
		
		getAccount()
		
		tableView.dataSource = self
		tableView.delegate = self
    }
	
	private func getAccount() {
		let accounts = Const.dataManager.fetchData(Account.self)
		if accounts.isEmpty { return }
		account = accounts.first!
		tableView.reloadSections([0], with: .automatic)
	}

}

extension SettingsViewController: UITableViewDataSource {
	
	
	func numberOfSections(in tableView: UITableView) -> Int {
		2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case 0:
				return 1
			default:
				return 3
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
			case 0:
				let cell = tableView.dequeue(ProfileTableViewCell.self, for: indexPath)
				if account != nil {
					cell.configer(account)
				}
				cell.accessoryType = .disclosureIndicator
				return cell
			default:
				var cell: SettingViewCell!
				switch indexPath.row {
					case 0:
						cell = tableView.dequeue(SettingViewCell.self, for: indexPath)
						cell.configure(text: "subscription".localized(), icon: UIImage(systemName: "creditcard"))
					case 1:
						cell = tableView.dequeue(SettingViewCell.self, for: indexPath)
						cell.configure(text: "app_language".localized(), icon: UIImage(systemName: "globe"))
					case 2:
						cell = tableView.dequeue(SettingViewCell.self, for: indexPath)
						cell.configure(text: "discover".localized(), icon: UIImage(systemName: "info"))
					default:
						return DefaultViewCell()
				}
				cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
				return cell
		}
	}
}

extension SettingsViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 0 {
			let memoriesVC = MemoriesViewController(account)
			memoriesVC.onUpdatedProfile = { account in
				self.account = account
				self.tableView.reloadSections([0], with: .automatic)
			}
			navigationController?.pushViewController(memoriesVC, animated: true)
		}else {
			
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch indexPath.section {
			case 0:
				return 90
			default:
				return 70
		}
	}
}
