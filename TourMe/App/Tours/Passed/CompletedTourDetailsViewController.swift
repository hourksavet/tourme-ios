//
//  CompletedTourDetailsViewController.swift
//  TourMe
//
//  Created by Savet on 8/7/25.
//

import UIKit

final class CompletedTourDetailsViewController: UIViewController {

	private enum Section: Int, CaseIterable {
		case banner
		case summary
		case export
		case routing
		case places
		case transportation
	}

	private let tour: Tour
	private let enableClose: Bool
	private let visitPlaces: [VisitPlace]
	private let places: [Place]
	private let totalDistance: Int
	private let totalDuration: Int
	private var expandedSections: Set<Section> = []

	private lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .insetGrouped)
		table.register(CompletedTourBannerCell.self)
		table.register(CompletedTourSummaryCell.self)
		table.register(CompletedTourActionCell.self)
		table.register(CompletedTourRouteCell.self)
		table.register(CompletedTourPlaceCell.self)
		table.register(IconTextViewCell.self)
		table.register(CompletedTourSectionHeaderView.self)
		table.showsVerticalScrollIndicator = false
		table.translatesAutoresizingMaskIntoConstraints = false
		return table
	}()

	init(_ tour: Tour, enableClose: Bool = true) {
		self.tour = tour
		self.enableClose = enableClose
		self.visitPlaces = (tour.visitPlaces?.array as? [VisitPlace]) ?? tour.visitPlaces?.compactMap({ $0 as? VisitPlace }) ?? []
		self.places = visitPlaces.compactMap(\ .place)
		self.totalDistance = visitPlaces.reduce(0) { partialResult, visitPlace in
			partialResult + Int(visitPlace.distance)
		}
		self.totalDuration = visitPlaces.reduce(0) { partialResult, visitPlace in
			partialResult + Int(visitPlace.duration / 1000)
		}
		super.init(nibName: nil, bundle: nil)
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

		title = "Completed Tour"
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

		if enableClose {
			navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeScreen))
		}

		tableView.dataSource = self
		tableView.delegate = self
	}

	@objc private func closeScreen() {
		dismiss(animated: true)
	}

	@objc private func shareTourSummary() {
		let tourMemoriesVC = TourMemoriesViewController(tour: tour)
		navigationController?.pushViewController(tourMemoriesVC, animated: true)
	}

	private func makeShareSummary() -> String {
		let placeNames = places.map { $0.name ?? "-" }.joined(separator: ", ")
		let completedAt = Self.dateFormatter.string(from: tour.endDate ?? Date())
		return [
			tour.name ?? "Completed Tour",
			"Completed: \(completedAt)",
			"Distance: \(kilometerText(from: totalDistance))",
			"Duration: \(durationText(from: totalDuration))",
			"Transportation: \(vehicleText())",
			"Places: \(placeNames)"
		].joined(separator: "\n")
	}

	private func vehicleText() -> String {
		switch tour.vehicle {
			case "CAR":
				return "Car"
			case "MOTORCYCLE":
				return "Motorcycle"
			default:
				return tour.vehicle?.capitalized ?? "Transportation"
		}
	}

	private func vehicleIcon() -> UIImage {
		if tour.vehicle == "CAR" {
			return UIImage(named: "ic_car") ?? UIImage(systemName: "car")!
		}
		if tour.vehicle == "MOTORCYCLE" {
			return UIImage(named: "ic_motorcycle") ?? UIImage(systemName: "motorcycle")!
		}
		return UIImage(systemName: "car")!
	}

	private func kilometerText(from meters: Int) -> String {
		guard meters > 0 else { return "0 km" }
		return "\(Int(round(Double(meters) / 1000.0))) km"
	}

	private func durationText(from seconds: Int) -> String {
		guard seconds > 0 else { return "0 min" }
		var remainingSeconds = seconds
		let daySeconds = 24 * 60 * 60
		let hourSeconds = 60 * 60
		let minuteSeconds = 60
		let days = remainingSeconds / daySeconds
		remainingSeconds %= daySeconds
		let hours = remainingSeconds / hourSeconds
		remainingSeconds %= hourSeconds
		let minutes = remainingSeconds / minuteSeconds

		var parts: [String] = []
		if days > 0 {
			parts.append("\(days) \("day".localized())")
		}
		if hours > 0 {
			parts.append("\(hours) \("h".localized())")
		}
		if minutes > 0 && days == 0 {
			parts.append("\(minutes) \("min".localized())")
		}
		return parts.isEmpty ? "0 min" : parts.joined(separator: " ")
	}

	private static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter
	}()
}

extension CompletedTourDetailsViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		Section.allCases.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = Section(rawValue: section) else { return 0 }
		switch section {
			case .routing:
				return expandedSections.contains(.routing) ? 1 : 0
			case .places:
				return expandedSections.contains(.places) ? places.count : 0
			case .transportation:
				return expandedSections.contains(.transportation) ? 1 : 0
			default:
				return 1
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = Section(rawValue: indexPath.section) else {
			return UITableViewCell()
		}

		switch section {
			case .banner:
				let cell = tableView.dequeue(CompletedTourBannerCell.self, for: indexPath)
				cell.configure(imageData: tour.banner)
				cell.selectionStyle = .none
				return cell
			case .summary:
				let cell = tableView.dequeue(CompletedTourSummaryCell.self, for: indexPath)
				cell.configure(title: tour.name ?? "Completed Tour", distance: kilometerText(from: totalDistance))
				cell.selectionStyle = .none
				return cell
			case .export:
				let cell = tableView.dequeue(CompletedTourActionCell.self, for: indexPath)
				cell.configure(title: "Export", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] in
					self?.shareTourSummary()
				}
				cell.selectionStyle = .none
				return cell
			case .routing:
				let cell = tableView.dequeue(CompletedTourRouteCell.self, for: indexPath)
				cell.configure(visitPlaces: visitPlaces, distanceText: kilometerText(from: totalDistance), durationText: durationText(from: totalDuration))
				cell.selectionStyle = .none
				return cell
			case .places:
				let cell = tableView.dequeue(CompletedTourPlaceCell.self, for: indexPath)
				cell.configure(with: places[indexPath.row])
				cell.selectionStyle = .none
				return cell
			case .transportation:
				let cell = tableView.dequeue(IconTextViewCell.self, for: indexPath)
				cell.configure(text: vehicleText(), icon: vehicleIcon(), isSelected: false)
				cell.selectionStyle = .none
				return cell
		}
	}
}

extension CompletedTourDetailsViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let section = Section(rawValue: indexPath.section) else { return 0 }
		switch section {
			case .banner:
				return tableView.frame.width * 3 / 5
			case .summary:
				return 60
			case .export:
				return 78
			case .routing:
				return 430
			case .places:
				return 96
			case .transportation:
				return 60
		}
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let section = Section(rawValue: section) else { return CGFloat.leastNormalMagnitude }
		switch section {
			case .routing, .places, .transportation:
				return 36
			default:
				return 20
		}
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let section = Section(rawValue: section) else { return nil }
		guard section == .routing || section == .places || section == .transportation else {
			return UIView(frame: .zero)
		}

		let header = tableView.dequeue(CompletedTourSectionHeaderView.self)
		switch section {
			case .routing:
				header.configure(title: "Routing", isExpanded: expandedSections.contains(.routing)) { [weak self] in
					self?.toggle(section: .routing)
				}
			case .places:
				header.configure(title: "Places to visit", badgeText: "\(places.count) places", isExpanded: expandedSections.contains(.places)) { [weak self] in
					self?.toggle(section: .places)
				}
			case .transportation:
				header.configure(title: "Transportation", isExpanded: expandedSections.contains(.transportation)) { [weak self] in
					self?.toggle(section: .transportation)
				}
			default:
				break
		}
		return header
	}

	private func toggle(section: Section) {
		if expandedSections.contains(section) {
			expandedSections.remove(section)
		} else {
			expandedSections.insert(section)
		}
		tableView.reloadSections(IndexSet(integer: section.rawValue), with: .automatic)
	}
}
