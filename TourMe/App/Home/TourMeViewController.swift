//
//  TourMeViewController.swift
//  TourMe
//
//  Created by Savet on 17/7/25.
//

import UIKit

struct PlaceListModel {
	let place: Place
	var isChose: Bool = false
	var choseOrder: Int = 0
}

class TourMeViewController: UIViewController {

	private lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .insetGrouped)
		table.showsVerticalScrollIndicator = false
		table.register(ProfileTableViewCell.self)
		table.register(TourViewCell.self)
		table.translatesAutoresizingMaskIntoConstraints = false
		return table
	}()
	
	private lazy var newTourBtn: RoundButton = {
		let button = RoundButton(radius: 20, activeColor: .primary, inactiveColor: .lightPrimary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("create_tour".localized(), for: .normal)
		button.titleLabel?.font = .defaultMedium(size: 20)
		button.isHidden = true
		button.addTarget(self, action: #selector(addNewTour), for: .touchUpInside)
		return button
	}()
	
	private var account: Account!
	
	private var savedTours: [Tour] = []
	
	private var completedTours: [Tour] = []
	
	override func loadView() {
		super.loadView()
		view.addSubview(tableView)
		view.addSubview(newTourBtn)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			newTourBtn.heightAnchor.constraint(equalToConstant: 50),
			newTourBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			newTourBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			newTourBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
		])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		title = "TourMe"
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
		
		let addTour = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addNewTour))
		
		navigationItem.rightBarButtonItem = addTour
		
		NotificationCenter.default.addObserver(self, selector: #selector(onSavedTour), name: Utils.observerName(.addTour), object: nil)
		
		getAccount()
		tableView.dataSource = self
		tableView.delegate = self
		getSavedTours()
		getCompletedTours()
		
	}

	private func getAccount() {
		let accounts = Const.dataManager.fetchData(Account.self)
		if accounts.isEmpty { return }
		account = accounts.first!
		tableView.reloadSections([0], with: .automatic)
	}
	
	private func getSavedTours() {
		let settings = NSPredicate(format: "startDate == nil")
		
		let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
		let tours = Const.dataManager.fetchData(Tour.self, predicate: settings, sortDescriptors: [sortDescriptor])
		self.savedTours.removeAll()
		if tours.isEmpty { return }
		self.savedTours = tours
		tableView.reloadSections([1], with: .automatic)
	}
	
	private func getCompletedTours() {
		let settings = NSPredicate(format: "endDate != nil")
		
		let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: false)
		let tours = Const.dataManager.fetchData(Tour.self, predicate: settings, sortDescriptors: [sortDescriptor])
		self.completedTours = tours
		tableView.reloadSections([2], with: .automatic)
		newTourBtn.isHidden = !(self.completedTours.isEmpty && savedTours.isEmpty)
	}
	
	@objc private func addNewTour() {
		let savedToursVC = CreateTourViewController(.add, enableClose: true).toNavigationController()
		savedToursVC.modalPresentationStyle = .overFullScreen
		present(savedToursVC, animated: true)
	}

	@objc private func onSavedTour(_ notification: Notification) {
		if let userInfo = notification.userInfo as? [String: Any] {
			if let tour = userInfo[String.tour] as? Tour {
				if let index = self.savedTours.firstIndex(where: { $0.id == tour.id }) {
					let indexPath = IndexPath(row: index, section: 1)
					self.tableView.reloadRows(at: [indexPath], with: .none)
				}else {
					savedTours.insert(tour, at: 0)
					tableView.reloadSections([1], with: .automatic)
				}
			}
		}
	}
	
	private func onDeleteTour(_ tour: Tour) {
		let context = Const.dataManager.context
		context.delete(tour)
		do {
			try context.save()
		}catch {
			print(error.localizedDescription)
		}
	}
}

extension TourMeViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case 0:
				return 1
			case 1:
				return savedTours.count
			default:
				return completedTours.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeue(ProfileTableViewCell.self, for: indexPath)
			if account != nil {
				cell.configer(account)
			}
			cell.accessoryType = .disclosureIndicator
			return cell
		}else if indexPath.section == 1 {
			let cell = tableView.dequeue(TourViewCell.self, for: indexPath)
			cell.configer(savedTours[indexPath.row])
			cell.accessoryType = .disclosureIndicator
			return cell
		}else {
			let cell = tableView.dequeue(TourViewCell.self, for: indexPath)
			cell.configer(completedTours[indexPath.row])
			cell.accessoryType = .disclosureIndicator
			return cell
		}
	}
	
}

extension TourMeViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 90
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 0 {
			let memoriesVC = MemoriesViewController(account)
			memoriesVC.onUpdatedProfile = { account in
				self.account = account
				self.tableView.reloadSections([0], with: .automatic)
			}
			navigationController?.pushViewController(memoriesVC, animated: true)
		}else if indexPath.section == 1 {
			let tourDetailsVC = SavedTourDetailsViewController(savedTours[indexPath.row], enableClose: true).toNavigationController()
			tourDetailsVC.modalPresentationStyle = .overFullScreen
			present(tourDetailsVC, animated: true)
		}else {
			let completedTourVC = CompletedTourDetailsViewController(completedTours[indexPath.row]).toNavigationController()
			completedTourVC.modalPresentationStyle = .overFullScreen
			present(completedTourVC, animated: true)
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
			case 0:
				return nil
			case 1:
				return "saved".localized()
			default:
				return "completed".localized()
		}
	}
	
	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if indexPath.section == 1 {
			let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			
				let image = UIImage(systemName: "restart.circle.fill")?.withRenderingMode(.alwaysTemplate)
				let startTour = UIAction(title: "start_tour".localized(), image: image) { action in
					self.savedTours[indexPath.row].startDate = Date()
					let context = Const.dataManager.context
					do {
						try context.save()
					}catch {}
					NotificationCenter.default.post(name: Utils.observerName(.statedTour), object: nil, userInfo: [String.tour: self.savedTours[indexPath.row]])
				}
				
				// Create an action for sharing
				let edit = UIAction(title: "edit".localized(), image: UIImage(systemName: "pencil")) { action in
					let createTourVC = CreateTourViewController(.edit, tour: self.savedTours[indexPath.row])
					self.navigationController?.pushViewController(createTourVC, animated: true)
				}
				
				// Create an action for delete with destructive attributes (highligh in red)
				let delete = UIAction(title: "delete".localized(), image: UIImage(systemName: "trash"), attributes: .destructive) { action in
					self.onDeleteTour(self.savedTours[indexPath.row])
					self.savedTours.remove(at: indexPath.row)
					self.tableView.deleteRows(at: [indexPath], with: .automatic)
				}
				
				// Create a UIMenu with all the actions as children
				return UIMenu(title: "", children: [startTour, edit, delete])
			}
			return contextMenuConfiguration
		}
		return nil
	}
}
