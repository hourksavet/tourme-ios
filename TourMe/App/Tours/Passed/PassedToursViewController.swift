//
//  PassedToursViewController.swift
//  TourMe
//
//  Created by Savet on 18/5/26.
//

import UIKit

final class PassedToursViewController: UIViewController {

	private lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .insetGrouped)
		table.showsVerticalScrollIndicator = false
		table.register(TourViewCell.self)
		table.translatesAutoresizingMaskIntoConstraints = false
		return table
	}()

	private lazy var emptyLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.normal)
		label.textColor = .secondaryLabel
		label.textAlignment = .center
		label.text = "No passed tours"
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private var tours: [Tour] = []

	override func loadView() {
		super.loadView()

		view.addSubview(tableView)
		view.addSubview(emptyLabel)

		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
			emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
		])
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .screenBackground
		tableView.dataSource = self
		tableView.delegate = self

		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Utils.observerName(.endedTour), object: nil)

		reloadData()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reloadData()
	}

	@objc private func reloadData() {
		let settings = NSPredicate(format: "endDate != nil")
		let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: false)
		tours = Const.dataManager.fetchData(Tour.self, predicate: settings, sortDescriptors: [sortDescriptor])
		tableView.reloadData()
		emptyLabel.isHidden = !tours.isEmpty
	}
}

extension PassedToursViewController: UITableViewDataSource {

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

extension PassedToursViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView(frame: .zero)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let completedTourVC = CompletedTourDetailsViewController(tours[indexPath.row]).toNavigationController()
		completedTourVC.modalPresentationStyle = .fullScreen
		present(completedTourVC, animated: true)
	}

}
