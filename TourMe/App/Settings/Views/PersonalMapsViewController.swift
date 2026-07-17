//
//  PersonalMapsViewController.swift
//  TourMe
//
//  Created by Savet on 17/7/26.
//

import MapLibre
import UIKit

final class PersonalMapsViewController: UIViewController {

	private enum Section: Int, CaseIterable {
		case base
		case roads
		case labels

		var title: String {
			switch self {
				case .base:
					return "Map features"
				case .roads:
					return "Road network"
				case .labels:
					return "Map labels"
			}
		}
	}

	private struct MapFeature: Hashable {
		let id: String
		let title: String
		let section: Section
		let layerMatcher: (String, String?) -> Bool

		static func == (lhs: MapFeature, rhs: MapFeature) -> Bool {
			lhs.id == rhs.id
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}

	private final class MapFeatureCell: UITableViewCell {

		private let checkBox = CheckBox()
		private let titleLabel = UILabel()

		override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
			super.init(style: style, reuseIdentifier: reuseIdentifier)

			selectionStyle = .none
			backgroundColor = .clear
			contentView.backgroundColor = .clear

			checkBox.isUserInteractionEnabled = false
			checkBox.translatesAutoresizingMaskIntoConstraints = false

			titleLabel.font = .default(size: UIFont.normal)
			titleLabel.textColor = .label
			titleLabel.translatesAutoresizingMaskIntoConstraints = false

			contentView.addSubview(checkBox)
			contentView.addSubview(titleLabel)

			NSLayoutConstraint.activate([
				checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
				checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
				checkBox.widthAnchor.constraint(equalToConstant: 24),
				checkBox.heightAnchor.constraint(equalToConstant: 24),

				titleLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 14),
				titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
				titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
			])
		}

		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		func configure(title: String, isSelected: Bool) {
			titleLabel.text = title
			checkBox.isChecked = isSelected
		}
	}

	private let userDefaultsKey = "personalMapSelectedFeatureIDs"

	private lazy var mapView: ToureMeMapView = {
		let map = ToureMeMapView(style: "map-style-default")
		map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		map.compassView.isHidden = true
		map.logoView.isHidden = true
		map.showsUserLocation = false
		map.translatesAutoresizingMaskIntoConstraints = false
		map.setCenter(CLLocationCoordinate2D(latitude: 11.5564, longitude: 104.9282), zoomLevel: 11, animated: false)
		return map
	}()

	private lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .insetGrouped)
		table.register(MapFeatureCell.self, forCellReuseIdentifier: String(describing: MapFeatureCell.self))
		table.backgroundColor = .screenBackground
		table.translatesAutoresizingMaskIntoConstraints = false
		return table
	}()


	private lazy var features: [MapFeature] = [
		MapFeature(id: "land", title: "Land use", section: .base) { layerID, sourceLayer in
			layerID.contains("landuse") || sourceLayer == "landuse"
		},
		MapFeature(id: "nature", title: "Parks and nature", section: .base) { layerID, sourceLayer in
			layerID.contains("landcover") || layerID.contains("park") || sourceLayer == "landcover"
		},
		MapFeature(id: "water", title: "Water", section: .base) { layerID, sourceLayer in
			layerID.contains("water") || sourceLayer == "water"
		},
		MapFeature(id: "buildings", title: "Buildings", section: .base) { layerID, sourceLayer in
			layerID.contains("building") || sourceLayer == "building"
		},
		MapFeature(id: "minor_roads", title: "Minor roads", section: .roads) { layerID, sourceLayer in
			sourceLayer == "transportation" && layerID.contains("minor")
		},
		MapFeature(id: "main_roads", title: "Main roads", section: .roads) { layerID, sourceLayer in
			sourceLayer == "transportation" && (layerID.contains("primary") || layerID.contains("secondary") || layerID.contains("tertiary") || layerID.contains("trunk"))
		},
		MapFeature(id: "road_labels", title: "Road labels", section: .labels) { layerID, sourceLayer in
			(sourceLayer == "transportation_name" || layerID.contains("road")) && layerID.contains("label")
		},
		MapFeature(id: "place_labels", title: "Place labels", section: .labels) { layerID, sourceLayer in
			layerID.contains("place") || sourceLayer == "place"
		},
		MapFeature(id: "poi_labels", title: "POI labels", section: .labels) { layerID, sourceLayer in
			layerID.contains("poi") || sourceLayer == "poi"
		}
	]

	private lazy var selectedFeatureIDs: Set<String> = loadSelectedFeatureIDs()
	private let barButtonAttributes: [NSAttributedString.Key: Any] = [
		.foregroundColor: UIColor.label,
		.font: UIFont.defaultMedium(size: UIFont.normal)
	]
	private var isEditingStyle = false
	private var mapFullScreenBottomConstraint: NSLayoutConstraint!
	private var mapEditHeightConstraint: NSLayoutConstraint!

	override func loadView() {
		super.loadView()

		view.addSubview(mapView)
		view.addSubview(tableView)
		tableView.isHidden = true

		mapFullScreenBottomConstraint = mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		mapEditHeightConstraint = mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)

		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: view.topAnchor),
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			mapFullScreenBottomConstraint,

			tableView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "map_style".localized()
		view.backgroundColor = .screenBackground
		edgesForExtendedLayout = [.top]
		extendedLayoutIncludesOpaqueBars = true
		configureNavigationBar()

		tableView.dataSource = self
		tableView.delegate = self

		applySelectedStyle()
	}

	private func configureNavigationBar() {
		let closeItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeScreen))
		closeItem.setTitleTextAttributes(barButtonAttributes, for: .normal)
		closeItem.setTitleTextAttributes(barButtonAttributes, for: .highlighted)
		navigationItem.leftBarButtonItem = closeItem
		updateRightBarButton()
		navigationController?.navigationBar.tintColor = .label

		let appearance = UINavigationBarAppearance()
		appearance.configureWithTransparentBackground()
		appearance.backgroundEffect = nil
		appearance.backgroundColor = .clear
		appearance.shadowColor = .clear
		appearance.titleTextAttributes = [
			.foregroundColor: UIColor.label,
			.font: UIFont.defaultMedium(size: UIFont.medium)
		]
		navigationItem.standardAppearance = appearance
		navigationItem.scrollEdgeAppearance = appearance
		navigationItem.compactAppearance = appearance
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.navigationBar.backgroundColor = .clear
	}

	private func updateRightBarButton() {
		let title = isEditingStyle ? "Save" : "Edit"
		let action = isEditingStyle ? #selector(saveStyle) : #selector(startEditingStyle)
		let item = UIBarButtonItem(title: title, style: .plain, target: self, action: action)
		item.setTitleTextAttributes(barButtonAttributes, for: .normal)
		item.setTitleTextAttributes(barButtonAttributes, for: .highlighted)
		navigationItem.rightBarButtonItem = item
	}

	@objc private func closeScreen() {
		dismiss(animated: true)
	}

	@objc private func startEditingStyle() {
		isEditingStyle = true
		updateRightBarButton()
		mapFullScreenBottomConstraint.isActive = false
		mapEditHeightConstraint.isActive = true
		tableView.isHidden = false

		UIView.animate(withDuration: 0.25) {
			self.view.layoutIfNeeded()
		}
	}

	@objc private func saveStyle() {
		UserDefaults.standard.set(Array(selectedFeatureIDs), forKey: userDefaultsKey)
		dismiss(animated: true)
	}

	private func features(in section: Section) -> [MapFeature] {
		features.filter { $0.section == section }
	}

	private func toggleFeature(_ feature: MapFeature) {
		if selectedFeatureIDs.contains(feature.id) {
			selectedFeatureIDs.remove(feature.id)
		} else {
			selectedFeatureIDs.insert(feature.id)
		}
		applySelectedStyle()
	}

	private func loadSelectedFeatureIDs() -> Set<String> {
		guard let storedIDs = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] else {
			return Set(features.map(\.id))
		}
		return Set(storedIDs)
	}

	private func applySelectedStyle() {
		guard let stylePath = Bundle.main.path(forResource: "map-style-default", ofType: "json"),
			  let styleData = try? Data(contentsOf: URL(fileURLWithPath: stylePath)),
			  var styleJSON = try? JSONSerialization.jsonObject(with: styleData) as? [String: Any],
			  let layers = styleJSON["layers"] as? [[String: Any]] else {
			return
		}

		let filteredLayers = layers.filter { layer in
			guard let layerID = layer["id"] as? String else { return true }
			let sourceLayer = layer["source-layer"] as? String
			let normalizedLayerID = layerID.lowercased()
			let matchedFeatures = features.filter { $0.layerMatcher(normalizedLayerID, sourceLayer) }

			guard !matchedFeatures.isEmpty else { return true }
			return matchedFeatures.contains { selectedFeatureIDs.contains($0.id) }
		}

		styleJSON["layers"] = filteredLayers

		guard let updatedData = try? JSONSerialization.data(withJSONObject: styleJSON, options: [.prettyPrinted]),
			  let updatedStyle = String(data: updatedData, encoding: .utf8) else {
			return
		}

		mapView.applyStyleJSON(updatedStyle, cacheKey: "personal-map-\(selectedFeatureIDs.sorted().joined(separator: "-"))")
	}
}

extension PersonalMapsViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		Section.allCases.count
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		Section(rawValue: section)?.title
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = Section(rawValue: section) else { return 0 }
		return features(in: section).count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MapFeatureCell.self), for: indexPath) as! MapFeatureCell
		guard let section = Section(rawValue: indexPath.section) else { return cell }
		let feature = features(in: section)[indexPath.row]
		cell.configure(title: feature.title, isSelected: selectedFeatureIDs.contains(feature.id))
		return cell
	}
}

extension PersonalMapsViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let section = Section(rawValue: indexPath.section) else { return }
		let feature = features(in: section)[indexPath.row]
		toggleFeature(feature)
		tableView.reloadRows(at: [indexPath], with: .automatic)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		56
	}
}
