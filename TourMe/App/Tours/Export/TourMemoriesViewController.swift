//
//  TourMemoriesViewController.swift
//  TourMe
//
//  Created by Savet on 26/5/26.
//

import UIKit

struct MemoryItem {
	let title: String
	let detail: String
	let icon: UIImage?
}

final class TourMemoriesViewController: UIViewController {

	private let items: [MemoryItem] = [
		MemoryItem(title: "Tour maps", detail: "Free", icon: UIImage(systemName: "map.fill")),
		MemoryItem(title: "Tour maps animation", detail: "Charge", icon: UIImage(systemName: "movieclapper.fill")),
		MemoryItem(title: "Fully tour", detail: "Charge", icon: UIImage(systemName: "movieclapper.fill")),
		MemoryItem(title: "Photo Album", detail: "Charge", icon: UIImage(systemName: "person.2.crop.square.stack.fill"))
	]

	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		tableView.backgroundColor = .clear
		tableView.showsVerticalScrollIndicator = false
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 58, bottom: 0, right: 0)
		tableView.register(TourMemoryOptionCell.self)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()

	private var tour: Tour!
	
	init(tour: Tour) {
		super.init(nibName: nil, bundle: nil)
		self.tour = tour
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		view.addSubview(tableView)

		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Memories"
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
		navigationItem.scrollEdgeAppearance = appearance

		tableView.dataSource = self
		tableView.delegate = self
		tableView.tableFooterView = UIView(frame: .zero)
	}
}

extension TourMemoriesViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		items.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeue(TourMemoryOptionCell.self, for: indexPath)
		cell.configure(with: items[indexPath.row])
		return cell
	}
}

extension TourMemoriesViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		switch indexPath.row {
		case 0:
			let vc = MapExportTemplateViewController(tour: tour)
			navigationController?.pushViewController(vc, animated: true)
		case 1:
			let vc = VideoTourAnimationViewController(tour: tour)
			navigationController?.pushViewController(vc, animated: true)
		default:
			break
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 70
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView(frame: .zero)
	}
}
