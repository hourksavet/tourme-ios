//
//  ChooseVisitedPlacesViewController.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit

class ChooseVisitedPlacesViewController: UIViewController {
	
	var onUpdatedChosePlace: (([Place]) -> Void)?
	
	var chosePlaces: [Place] = [] {
		didSet {
			chosePlacesUpdated()
		}
	}
	
	var visitPlaces: [VisitPlace] = [] {
		didSet {
			onSetVisitPlaces()
		}
	}
	
	private var allPlaceModels: [PlaceListModel] = []
	
	private var placeListModels: [PlaceListModel] = []
	
	private var isFavorite: Bool = false
	
	private lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .insetGrouped)
		table.showsVerticalScrollIndicator = false
		table.register(FavoriteViewCell.self)
		table.register(PlaceTableViewCell.self)
		table.translatesAutoresizingMaskIntoConstraints = false
		return table
	}()
	
	private var padding: UIEdgeInsets!
	
	var textSearch: String = "" {
		didSet {
			searchPlaces()
		}
	}
	
	init(_ padding: UIEdgeInsets!) {
		super.init(nibName: nil, bundle: nil)
		self.padding = padding
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.right),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .screenBackground
		
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: padding.bottom + view.safeAreaInsets.bottom))
		
		tableView.dataSource = self
		tableView.delegate = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(onAddPlace), name: Utils.observerName(.addPlace), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onPlaceDeleted), name: Utils.observerName(.deletePlace), object: nil)
		
		getPlaces(isFavorite)
	}
	
	@objc private func getPlaces(_ isFavorite: Bool) {
		var settings: NSPredicate!
		if isFavorite {
			settings = NSPredicate(format: "isFavorite = true AND visitCount > 0")
		}else {
			settings = NSPredicate(format: "visitCount > 0")
		}
		placeListModels.removeAll()
		let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
		let places = Const.dataManager.fetchData(Place.self, predicate: settings, sortDescriptors: [sortDescriptor])
		for place in places {
			let placeModel = PlaceListModel(place: place)
			self.placeListModels.append(placeModel)
		}
		self.allPlaceModels = self.placeListModels
		if textSearch != "" {
			searchPlaces()
		}
		tableView.reloadData()
		tableView.refreshControl?.endRefreshing()
		if chosePlaces.count > 0 {
			chosePlacesUpdated()
		}
	}
	
	private func searchPlaces() {
		if textSearch == "" {
			placeListModels = allPlaceModels
		}else {
			placeListModels = allPlaceModels.filter { $0.place.name?.lowercased().contains(textSearch.lowercased()) == true }
		}
		tableView.reloadData()
	}
	
	@objc private func onAddPlace(_ notification: Notification) {
		if let userInfo = notification.userInfo as? [String: Any] {
			if let place = userInfo[String.place] as? Place {
				if let index = self.placeListModels.firstIndex(where: { $0.place.id == place.id }) {
					let indexPath = IndexPath(row: index + 1, section: 0)
					self.tableView.reloadRows(at: [indexPath], with: .none)
				}else {
					getPlaces(isFavorite)
				}
			}
		}
	}
	
	@objc private func onPlaceDeleted(_ notification: Notification) {
		if let userInfo = notification.userInfo as? [String: Any] {
			if let place = userInfo[String.place] as? Place {
				if let index = self.placeListModels.firstIndex(where: { $0.place.id == place.id }) {
					self.placeListModels.remove(at: index)
					let indexPath = IndexPath(row: index + 1, section: 0)
					self.tableView.deleteRows(at: [indexPath], with: .automatic)
				}
			}
		}
	}
	
	private func onDeletePlace(_ place: Place) {
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
	
	private func tapChoosePlace( at indexPath: IndexPath) {
		if let index = chosePlaces.firstIndex(where: { $0.id == placeListModels[indexPath.row - 1].place.id }) {
			chosePlaces.remove(at: index)
			placeListModels[indexPath.row - 1].isChose = false
			placeListModels[indexPath.row - 1].choseOrder = 0
			chosePlacesUpdated()
		}else {
			chosePlaces.append(placeListModels[indexPath.row - 1].place)
			placeListModels[indexPath.row - 1].isChose = true
			placeListModels[indexPath.row - 1].choseOrder = chosePlaces.count - 1
		}
		tableView.reloadRows(at: [indexPath], with: .automatic)
		onUpdatedChosePlace?(chosePlaces)
	}
	
	private func chosePlacesUpdated() {
		for index in 0..<placeListModels.count {
			placeListModels[index].choseOrder = 0
			placeListModels[index].isChose = false
		}
		for choseIndex in 0..<chosePlaces.count {
			if let index = placeListModels.firstIndex(where: { $0.place.id == chosePlaces[choseIndex].id }) {
				placeListModels[index].choseOrder = choseIndex
				placeListModels[index].isChose = true
			}
		}
		tableView.reloadData()
	}
	
	private func onSetVisitPlaces() {
		var mergedPlaces: [Place] = []
		var seenIDs = Set<String>()
		for place in chosePlaces {
			guard let id = place.id?.uuidString, seenIDs.insert(id).inserted else { continue }
			mergedPlaces.append(place)
		}
		for visitPl in visitPlaces {
			guard let place = visitPl.place, let id = place.id?.uuidString, seenIDs.insert(id).inserted else { continue }
			mergedPlaces.append(place)
		}
		chosePlaces = mergedPlaces
	}
}

extension ChooseVisitedPlacesViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return placeListModels.count + 1
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
		cell.configure(with: placeListModels[indexPath.row - 1])
		cell.selectedBackgroundView = UIView()
		return cell
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if indexPath.row == 0 { return indexPath }
		let placeID = placeListModels[indexPath.row - 1].place.id!.uuidString
		for visitPl in visitPlaces {
			if visitPl.place?.id?.uuidString == placeID {
				if visitPl.departure_date == nil {
					return indexPath
				}else {
					return nil
				}
			}
		}
		return indexPath
	}
}

extension ChooseVisitedPlacesViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.row == 0 {
			let cell = tableView.cellForRow(at: indexPath) as! FavoriteViewCell
			cell.isFavorite.toggle()
			isFavorite = cell.isFavorite
			getPlaces(isFavorite)
		}else {
			tapChoosePlace(at: indexPath)
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 50
		}
		return 90
	}
	
	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if !chosePlaces.isEmpty || !visitPlaces.isEmpty {
			return nil
		}
		let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			// Create an action for sharing
			let edit = UIAction(title: "edit".localized(), image: UIImage(systemName: "pencil")) { action in
				let placeDetailsVC = PlaceDetailsViewController(action: .edit, place: self.placeListModels[indexPath.row - 1].place)
				self.navigationController?.pushViewController(placeDetailsVC, animated: true)
			}
			
			// Create an action for delete with destructive attributes (highligh in red)
			let delete = UIAction(title: "delete".localized(), image: UIImage(systemName: "trash"), attributes: .destructive) { action in
				self.onDeletePlace(self.placeListModels[indexPath.row - 1].place)
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
