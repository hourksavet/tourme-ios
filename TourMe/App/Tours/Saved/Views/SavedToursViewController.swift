//
//  SavedToursViewController.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import Combine
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
		label.text = "no_saved_tours".localized()
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
		
	private let viewModel = SavedToursViewModel()
	private var isFavorite: Bool = false
	private var tours: [Tour] = []
	private var cancellables = Set<AnyCancellable>()
		
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
			NSAttributedString.Key.foregroundColor: UIColor.primary,
			NSAttributedString.Key.font: UIFont.default(size: UIFont.normal)
		]
		navigationItem.standardAppearance = appearance
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(closeScreen))
			
		tableView.dataSource = self
		tableView.delegate = self
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
			
		bindViewModel()
		viewModel.send(.viewDidLoad)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel.send(.viewWillAppear)
	}
		
	@objc private func clickedFavorite() {
		viewModel.send(.toggleFavorite)
	}
		
	@objc private func closeScreen() {
		dismiss(animated: true)
	}

	private func bindViewModel() {
		viewModel.$state
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				self?.tours = state.tours
				self?.isFavorite = state.isFavorite
				self?.emptyLabel.isHidden = !state.isEmpty
				self?.tableView.reloadData()
			}
			.store(in: &cancellables)

		let tourChanged = NotificationCenter.default.publisher(for: Utils.observerName(.addTour))
			.merge(with: NotificationCenter.default.publisher(for: Utils.observerName(.deleteTour)))
			.merge(with: NotificationCenter.default.publisher(for: Utils.observerName(.statedTour)))
			.merge(with: NotificationCenter.default.publisher(for: Utils.observerName(.endedTour)))

		tourChanged
			.sink { [weak self] _ in
				self?.viewModel.send(.tourChanged)
			}
			.store(in: &cancellables)
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
			let edit = UIAction(title: "edit".localized(), image: UIImage(systemName: "pencil")) { _ in
				let createTourVC = CreateTourViewController(
					.edit,
					tour: self.tours[indexPath.row],
					enableClose: true
				).toNavigationController()
				createTourVC.modalPresentationStyle = .overFullScreen
				self.present(createTourVC, animated: true)
			}
				
			let delete = UIAction(title: "delete".localized(), image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
				self.viewModel.delete(self.tours[indexPath.row])
			}
				
			return UIMenu(title: "", children: [edit, delete])
		}
		return contextMenuConfiguration
	}
}
