//
//  VisitedPlacesViewController.swift
//  TourMe
//
//  Created by Savet on 18/5/26.
//

import Combine
import UIKit

class VisitedPlacesViewController: UIViewController {

	private let viewModel = PlaceListViewModel(source: .visited)
	private var placeModels: [PlaceListModel] = []
	private var isFavorite: Bool = false
	private var cancellables = Set<AnyCancellable>()

	private lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .insetGrouped)
		table.showsVerticalScrollIndicator = false
		table.register(FavoriteViewCell.self)
		table.register(PlaceTableViewCell.self)
		table.translatesAutoresizingMaskIntoConstraints = false
		return table
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

		view.backgroundColor = .screenBackground
		tableView.dataSource = self
		tableView.delegate = self

		bindViewModel()
		viewModel.send(.viewDidLoad)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel.send(.viewWillAppear)
	}

	private func bindViewModel() {
		viewModel.$state
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				self?.placeModels = state.places
				self?.isFavorite = state.isFavorite
				self?.tableView.reloadData()
			}
			.store(in: &cancellables)

		NotificationCenter.default.publisher(for: Utils.observerName(.addPlace))
			.merge(with: NotificationCenter.default.publisher(for: Utils.observerName(.deletePlace)))
			.sink { [weak self] _ in
				self?.viewModel.send(.placeChanged)
			}
			.store(in: &cancellables)
	}
}

extension VisitedPlacesViewController: UITableViewDataSource {

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

extension VisitedPlacesViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.row == 0 {
			viewModel.send(.toggleFavorite)
		} else {
			let place = placeModels[indexPath.row - 1].place
			let placeDetailsVC = PlaceDetailsViewController(action: .edit, place: place, enableClose: true).toNavigationController()
			placeDetailsVC.modalPresentationStyle = .overFullScreen
			present(placeDetailsVC, animated: true)
		}
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 50
		}
		return 90
	}

	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard indexPath.row > 0 else { return nil }

		let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			let edit = UIAction(title: "edit".localized(), image: UIImage(systemName: "pencil")) { _ in
				let place = self.placeModels[indexPath.row - 1].place
				let placeDetailsVC = PlaceDetailsViewController(action: .edit, place: place, enableClose: true).toNavigationController()
				placeDetailsVC.modalPresentationStyle = .overFullScreen
				self.present(placeDetailsVC, animated: true)
			}

			let delete = UIAction(title: "delete".localized(), image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
				self.viewModel.delete(self.placeModels[indexPath.row - 1].place)
			}

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
