//
//  SavedToursViewController.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit

class SavedToursViewController: UIViewController {
	
	private lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .insetGrouped)
		table.showsVerticalScrollIndicator = false
		table.register(TourViewCell.self)
		table.register(FavoriteViewCell.self)
		table.translatesAutoresizingMaskIntoConstraints = false
		return table
	}()
	
	private lazy var emptyLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.normal)
		label.textColor = .secondaryLabel
		label.textAlignment = .center
		label.text = "No saved tours"
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private var isFavorite: Bool = false
	
	private var tours: [Tour] = []
	
	override func loadView() {
		super.loadView()
		view.addSubview(tableView)
		view.addSubview(emptyLabel)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
			emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
			emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
		])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .screenBackground
		navigationController?.navigationBar.tintColor = .primary
		navigationItem.largeTitleDisplayMode = .never
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor:UIColor.primary,
			NSAttributedString.Key.font: UIFont.default(size: UIFont.normal)
		]
		navigationItem.standardAppearance = appearance
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(closeScreen))
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
		
		NotificationCenter.default.addObserver(self, selector: #selector(onSavedTour), name: Utils.observerName(.addTour), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(onTourDeleted), name: Utils.observerName(.deleteTour), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onTourStateChanged), name: Utils.observerName(.statedTour), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onTourStateChanged), name: Utils.observerName(.endedTour), object: nil)
		getSavedTours(isFavorite)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		getSavedTours(isFavorite)
	}

	private func getSavedTours(_ isFavorite: Bool) {
		var settings: NSPredicate?
		if isFavorite {
			settings = NSPredicate(format: "isFavorite = true AND startDate == nil")
		}else {
			settings = NSPredicate(format: "startDate == nil")
		}
		let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
		let tours = Const.dataManager.fetchData(Tour.self, predicate: settings, sortDescriptors: [sortDescriptor])
		
		emptyLabel.isHidden = !tours.isEmpty
		
		self.tours = tours
		tableView.reloadData()
	}
	
	@objc private func clickedFavorite() {
		isFavorite.toggle()
		getSavedTours(isFavorite)
	}
	
	@objc private func closeScreen() {
		dismiss(animated: true)
	}
	
	@objc private func onTourDeleted(_ notification: Notification) {
		if let userInfo = notification.userInfo as? [String: Any] {
			if let tour = userInfo[String.tour] as? Tour {
				if let index = self.tours.firstIndex(where: { $0.id == tour.id }) {
					self.tours.remove(at: index)
					let indexPath = IndexPath(row: index, section: 0)
					self.tableView.deleteRows(at: [indexPath], with: .automatic)
				}
			}
		}
		emptyLabel.isHidden = !tours.isEmpty
	}
	
	@objc private func onSavedTour(_ notification: Notification) {
		if let userInfo = notification.userInfo as? [String: Any] {
			if let tour = userInfo[String.tour] as? Tour {
				if let index = self.tours.firstIndex(where: { $0.id == tour.id }) {
					let indexPath = IndexPath(row: index, section: 0)
					self.tableView.reloadRows(at: [indexPath], with: .none)
				}else {
					if (isFavorite && tour.isFavorite) || !isFavorite {
						tours.insert(tour, at: 0)
						tableView.reloadData()
					}
				}
			}
		}
		emptyLabel.isHidden = !tours.isEmpty
	}

	@objc private func onTourStateChanged() {
		getSavedTours(isFavorite)
	}
	
	private func onDeleteTour(_ tour: Tour) {
		let context = Const.dataManager.context
		context.delete(tour)
		do {
			try context.save()
			self.navigationController?.popViewController(animated: true)
			NotificationCenter.default.post(name: Utils.observerName(.deleteTour), object: nil, userInfo: [String.tour: tour])
		}catch {
			print(error.localizedDescription)
		}
	}
}

extension SavedToursViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tours.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeue(TourViewCell.self, for: indexPath)
		cell.configer(tours[indexPath.row])
		cell.accessoryType = .disclosureIndicator
		return cell
	}
	
}

extension SavedToursViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let tourDetailsVC = SavedTourDetailsViewController(
			tours[indexPath.row],
			enableClose: true
		).toNavigationController()
		tourDetailsVC.modalPresentationStyle = .overFullScreen
		present(tourDetailsVC, animated: true)
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView(frame: .zero)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 90
	}
	
	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			// Create an action for sharing
			let edit = UIAction(title: "edit".localized(), image: UIImage(systemName: "pencil")) { action in
				let createTourVC = CreateTourViewController(
					.edit,
					tour: self.tours[indexPath.row],
					enableClose: true
				).toNavigationController()
				createTourVC.modalPresentationStyle = .overFullScreen
				self.present(createTourVC, animated: true)
			}
			
			// Create an action for delete with destructive attributes (highligh in red)
			let delete = UIAction(title: "delete".localized(), image: UIImage(systemName: "trash"), attributes: .destructive) { action in
				self.onDeleteTour(self.tours[indexPath.row])
			}
			
			// Create a UIMenu with all the actions as children
			return UIMenu(title: "", children: [edit, delete])
		}
		return contextMenuConfiguration
	}
}
