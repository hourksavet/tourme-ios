//
//  AllPlacesViewController.swift
//  TourMe
//
//  Created by Savet on 31/7/25.
//

import UIKit

class AllPlacesViewController: UIViewController {

	private var placeModels: [PlaceListModel] = []
	
	private var isFavorite: Bool = false
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.backgroundColor = .clear
		tableView.showsVerticalScrollIndicator = false
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.register(PlaceTableViewCell.self)
		tableView.register(FavoriteViewCell.self)
		return tableView
	}()
	
	override func loadView() {
		super.loadView()
		
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "places".localized()
		
		view.backgroundColor = .screenBackground
		navigationController?.navigationBar.tintColor = .primary
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.largeTitleTextAttributes = [
			.font: UIFont.defaultBold(size: 30),
			.foregroundColor: UIColor.primary
		]
		appearance.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor:UIColor.primary,
			NSAttributedString.Key.font: UIFont.default(size: UIFont.normal)
		]
		navigationItem.standardAppearance = appearance
		
		let addPlace = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addNewPlace))
		let savedPlace = UIBarButtonItem(image: UIImage(systemName: "folder"), style: .done, target: self, action: #selector(openSavedPlaces))
		navigationItem.rightBarButtonItems = [addPlace, savedPlace]
		
		NotificationCenter.default.addObserver(self, selector: #selector(onSavePlace), name: Utils.observerName(.addPlace), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onPlaceDeleteed), name: Utils.observerName(.deletePlace), object: nil)
		
		tableView.dataSource = self
		tableView.delegate = self
		
		getPlaces(false)
		
	}
	
	@objc private func addNewPlace() {
		let addPlaceVC = PlaceDetailsViewController(action: .add, enableClose: true).toNavigationController()
		addPlaceVC.modalPresentationStyle = .overFullScreen
		present(addPlaceVC, animated: true)
	}
	
	@objc private func openSavedPlaces() {
		let savedPlaceVC = SavedPlacesViewController().toNavigationController()
		savedPlaceVC.modalPresentationStyle = .overFullScreen
		present(savedPlaceVC, animated: true)
	}
	
	@objc private func getPlaces(_ isFavorite: Bool) {
		var settings: NSPredicate?
		placeModels.removeAll()
		if isFavorite {
			settings = NSPredicate(format: "isFavorite = true")
		}
		let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
		let places = Const.dataManager.fetchData(Place.self, predicate: settings, sortDescriptors: [sortDescriptor])
		for place in places {
			placeModels.append(PlaceListModel(place: place))
		}
		tableView.reloadData()
	}
	
	@objc private func onSavePlace(_ notification: Notification) {
		if let userInfo = notification.userInfo as? [String: Any] {
			if let place = userInfo[String.place] as? Place {
				if let index = placeModels.firstIndex(where: { $0.place.id == place.id }) {
					let indexPath = IndexPath(row: index + 1, section: 0)
					tableView.reloadRows(at: [indexPath], with: .automatic)
				}else {
					let placeModel = PlaceListModel(place: place)
					placeModels.insert(placeModel, at: 0)
					tableView.reloadData()
				}
			}
		}
	}
	
	@objc private func onPlaceDeleteed(_ notification: Notification) {
		if let userInfo = notification.userInfo as? [String: Any] {
			if let place = userInfo[String.place] as? Place {
				if let index = placeModels.firstIndex(where: { $0.place.id == place.id }) {
					placeModels.remove(at: index)
					let indexPath = IndexPath(row: index + 1, section: 0)
					tableView.deleteRows(at: [indexPath], with: .automatic)
				}
			}
		}
	}

}

extension AllPlacesViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return placeModels.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = tableView.dequeue(FavoriteViewCell.self, for: indexPath)
			cell.isFavorite = isFavorite
			cell.setTitle("your_favorite_places".localized())
			cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
			cell.accessoryType = .disclosureIndicator
			cell.selectedBackgroundView = UIView()
			return cell
		}
		let cell = tableView.dequeue(PlaceTableViewCell.self, for: indexPath)
		cell.configure(with: placeModels[indexPath.row - 1])
		cell.accessoryType = .disclosureIndicator
		return cell
	}
	
	
	
}

extension AllPlacesViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 50
		}
		return 90
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.row == 0 {
			let cell = tableView.cellForRow(at: indexPath) as! FavoriteViewCell
			cell.isFavorite.toggle()
			isFavorite = cell.isFavorite
			getPlaces(isFavorite)
		}else {
			let place = self.placeModels[indexPath.row - 1].place
			let placeDetailsVC = PlaceDetailsViewController(action: .edit, place: place, enableClose: true).toNavigationController()
			placeDetailsVC.modalPresentationStyle = .overFullScreen
			self.present(placeDetailsVC, animated: true)
		}
	}
	
	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			// Create an action for sharing
			let edit = UIAction(title: "edit".localized(), image: UIImage(systemName: "pencil")) { action in
				let place = self.placeModels[indexPath.row - 1].place
				let placeDetailsVC = PlaceDetailsViewController(action: .edit, place: place, enableClose: true).toNavigationController()
				placeDetailsVC.modalPresentationStyle = .overFullScreen
				self.present(placeDetailsVC, animated: true)
			}
			
			// Create an action for delete with destructive attributes (highligh in red)
			let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
				let place = self.placeModels[indexPath.row - 1].place
				let context = Const.dataManager.context
				context.delete(place)
				do {
					try context.save()
					self.navigationController?.popViewController(animated: true)
					NotificationCenter.default.post(name: Utils.observerName(.deletePlace), object: nil, userInfo: [String.place: place])
				}catch {
					print(error.localizedDescription)
				}
			}
			
			// Create a UIMenu with all the actions as children
			return UIMenu(title: "", children: [edit, delete])
		}
		return contextMenuConfiguration
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView(frame: .zero)
	}
}
