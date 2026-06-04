//
//  MapCustomCheckListViewController.swift
//  TourMe
//
//  Created by Savet on 4/6/26.
//

import UIKit

private struct MapStyleOption {
	let key: String
	let title: String
	var isEnabled: Bool
}

private final class MapStyleOptionCell: UITableViewCell {

	static let reuseIdentifier = "MapStyleOptionCell"

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: 16)
		label.textColor = .primary
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let toggleSwitch: UISwitch = {
		let toggle = UISwitch()
		toggle.onTintColor = .primary
		toggle.translatesAutoresizingMaskIntoConstraints = false
		return toggle
	}()

	var onToggle: ((Bool) -> Void)?

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		contentView.addSubview(titleLabel)
		contentView.addSubview(toggleSwitch)
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
			titleLabel.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: -12),

			toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
		toggleSwitch.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with option: MapStyleOption, onToggle: @escaping (Bool) -> Void) {
		titleLabel.text = option.title
		toggleSwitch.isOn = option.isEnabled
		self.onToggle = onToggle
	}

	@objc private func toggleChanged() {
		onToggle?(toggleSwitch.isOn)
	}
}

class MapCustomCheckListViewController: UIViewController {

	var onApplyStyleJSON: ((String) -> Void)?

	private enum Section: Int, CaseIterable {
		case layers
		case borders
		case labels
		case buildings

		var title: String {
			switch self {
			case .layers:
				return "Map Layers"
			case .borders:
				return "Borders"
			case .labels:
				return "Labels"
			case .buildings:
				return "Buildings"
			}
		}
	}

	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.backgroundColor = .clear
		tableView.register(MapStyleOptionCell.self, forCellReuseIdentifier: MapStyleOptionCell.reuseIdentifier)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()

	private var sections: [[MapStyleOption]] = [
		[
			MapStyleOption(key: "tree", title: "Tree", isEnabled: true),
			MapStyleOption(key: "water", title: "Water", isEnabled: true),
			MapStyleOption(key: "garden", title: "Garden", isEnabled: true),
			MapStyleOption(key: "highway", title: "Highway", isEnabled: true),
			MapStyleOption(key: "mediumWay", title: "Medium way", isEnabled: true),
			MapStyleOption(key: "smallRoad", title: "Small road", isEnabled: true),
			MapStyleOption(key: "roadName", title: "Road name", isEnabled: true)
		],
		[
			MapStyleOption(key: "borderDistrict", title: "Border district", isEnabled: true),
			MapStyleOption(key: "borderProvince", title: "Border province", isEnabled: true),
			MapStyleOption(key: "borderCity", title: "Border city", isEnabled: true)
		],
		[
			MapStyleOption(key: "districtName", title: "District name", isEnabled: true),
			MapStyleOption(key: "provinceName", title: "Province name", isEnabled: true),
			MapStyleOption(key: "cityName", title: "City name", isEnabled: true)
		],
		[
			MapStyleOption(key: "privateBuilding", title: "Private building", isEnabled: true),
			MapStyleOption(key: "publicBuilding", title: "Public building", isEnabled: true)
		]
	]

	override func loadView() {
		super.loadView()
		view.addSubview(tableView)

		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Personalize"
		view.backgroundColor = .screenBackground
		tableView.dataSource = self
		tableView.delegate = self
		navigationItem.leftBarButtonItem = UIBarButtonItem(
			title: "Apply",
			style: .done,
			target: self,
			action: #selector(applyStyleJSON)
		)
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "xmark"),
			style: .plain,
			target: self,
			action: #selector(closeScreen)
		)
	}
	
	@objc private func closeScreen() {
		dismiss(animated: true)
	}

	@objc private func applyStyleJSON() {
		let styleJSON = generatedStyleJSON()
		onApplyStyleJSON?(styleJSON)
		dismiss(animated: true)
	}

	private func updateOption(at indexPath: IndexPath, isEnabled: Bool) {
		sections[indexPath.section][indexPath.row].isEnabled = isEnabled
	}

	private func generatedStyleJSON() -> String {
		guard var style = loadBaseStyle() else {
			return "{}"
		}
		var layers = (style["layers"] as? [[String: Any]]) ?? []
		let options = optionStates()

		let removableLayerIDs = [
			"water", "water_outline",
			"road_tertiary_secondary_casing", "road_tertiary_secondary",
			"road_primary_casing", "road_primary",
			"road_trunk_casing", "road_trunk",
			"road_motorway_casing", "road_motorway",
			"road_ramp_casing", "road_ramp",
			"road_roundabout",
			"road_major_label",
			"boundary_province", "boundary_city",
			"place_label_district", "place_label_province", "place_label_city",
			"terminal-building",
			"runtime_landcover_wood",
			"runtime_garden_overlay_park", "runtime_garden_overlay_landuse",
			"runtime_road_minor_casing", "runtime_road_minor",
			"runtime_boundary_district",
			"runtime_building_private"
		]
		layers.removeAll { layer in
			removableLayerIDs.contains(layer["id"] as? String ?? "")
		}

		if options["tree"] == true {
			insertLayers([makeTreeLayer()], before: "water", into: &layers)
		}
		if options["water"] == true {
			insertLayers([makeWaterLayer(), makeWaterOutlineLayer()], before: "road_tertiary_secondary_casing", into: &layers)
		}
		if options["garden"] == true {
			insertLayers(makeGardenLayers(), before: "airport-label", into: &layers)
		}
		if options["smallRoad"] == true {
			insertLayers(makeSmallRoadLayers(), before: "road_tertiary_secondary_casing", into: &layers)
		}
		if options["mediumWay"] == true {
			insertLayers(makeMediumRoadLayers(), before: "road_trunk_casing", into: &layers)
		}
		if options["highway"] == true {
			insertLayers(makeHighwayLayers(), before: "road_tunnel", into: &layers)
		}
		if options["privateBuilding"] == true {
			insertLayers([makePrivateBuildingLayer()], before: "road_tertiary_secondary_casing", into: &layers)
		}
		if options["publicBuilding"] == true {
			insertLayers([makePublicBuildingLayer()], before: "place_label_province", into: &layers)
		}
		if options["borderProvince"] == true {
			insertLayers([makeProvinceBoundaryLayer()], before: "place_label_province", into: &layers)
		}
		if options["borderCity"] == true {
			insertLayers([makeCityBoundaryLayer()], before: "place_label_province", into: &layers)
		}
		if options["borderDistrict"] == true {
			insertLayers([makeDistrictBoundaryLayer()], before: "place_label_province", into: &layers)
		}
		if options["roadName"] == true {
			insertLayers([makeRoadLabelLayer()], before: "airport-label", into: &layers)
		}
		if options["provinceName"] == true {
			insertLayers([makeProvinceLabelLayer()], before: "place-point-layer", into: &layers)
		}
		if options["districtName"] == true {
			insertLayers([makeDistrictLabelLayer()], before: "place-point-layer", into: &layers)
		}
		if options["cityName"] == true {
			insertLayers([makeCityLabelLayer()], before: "place-point-layer", into: &layers)
		}

		style["layers"] = layers
		guard JSONSerialization.isValidJSONObject(style),
			let data = try? JSONSerialization.data(withJSONObject: style, options: [.prettyPrinted, .sortedKeys]),
			let json = String(data: data, encoding: .utf8) else {
			return "{}"
		}
		return json
	}

	private func loadBaseStyle() -> [String: Any]? {
		guard let stylePath = Bundle.main.path(forResource: "map-style-road", ofType: "json"),
			let data = try? Data(contentsOf: URL(fileURLWithPath: stylePath)),
			let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
			return nil
		}
		return object
	}

	private func optionStates() -> [String: Bool] {
		sections
			.flatMap { $0 }
			.reduce(into: [String: Bool]()) { result, option in
				result[option.key] = option.isEnabled
			}
	}

	private func insertLayers(_ newLayers: [[String: Any]], before anchorID: String, into layers: inout [[String: Any]]) {
		if let anchorIndex = layers.firstIndex(where: { $0["id"] as? String == anchorID }) {
			layers.insert(contentsOf: newLayers, at: anchorIndex)
		} else {
			layers.append(contentsOf: newLayers)
		}
	}

	private func makeTreeLayer() -> [String: Any] {
		[
			"id": "runtime_landcover_wood",
			"type": "fill",
			"source": "openmaptiles",
			"source-layer": "landcover",
			"filter": ["==", "class", "wood"],
			"paint": [
				"fill-color": "#DDF0D3",
				"fill-opacity": 0.7
			]
		]
	}

	private func makeWaterLayer() -> [String: Any] {
		[
			"id": "water",
			"type": "fill",
			"source": "openmaptiles",
			"source-layer": "water",
			"paint": [
				"fill-color": "#A9D7F3"
			]
		]
	}

	private func makeWaterOutlineLayer() -> [String: Any] {
		[
			"id": "water_outline",
			"type": "line",
			"source": "openmaptiles",
			"source-layer": "water",
			"paint": [
				"line-color": "#94CAE8",
				"line-width": [
					"base": 1.2,
					"stops": [[7, 0.6], [22, 3]]
				]
			]
		]
	}

	private func makeGardenLayers() -> [[String: Any]] {
		[
			[
				"id": "runtime_garden_overlay_park",
				"type": "fill",
				"source": "openmaptiles",
				"source-layer": "park",
				"filter": ["all", ["==", "$type", "Polygon"], ["==", "subclass", "garden"]],
				"paint": [
					"fill-color": "#DFF0D5",
					"fill-opacity": 0.9
				]
			],
			[
				"id": "runtime_garden_overlay_landuse",
				"type": "fill",
				"source": "openmaptiles",
				"source-layer": "landuse",
				"filter": ["all", ["==", "$type", "Polygon"], ["==", "class", "park"], ["==", "subclass", "garden"]],
				"paint": [
					"fill-color": "#DFF0D5",
					"fill-opacity": 0.9
				]
			]
		]
	}

	private func makeSmallRoadLayers() -> [[String: Any]] {
		[
			[
				"id": "runtime_road_minor_casing",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"minzoom": 12,
				"filter": ["all", ["==", "$type", "LineString"], ["==", "class", "minor"]],
				"paint": [
					"line-color": "#D0D4D7",
					"line-width": ["base": 1.25, "stops": [[12, 1.8], [22, 24]]]
				]
			],
			[
				"id": "runtime_road_minor",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"minzoom": 12,
				"filter": ["all", ["==", "$type", "LineString"], ["==", "class", "minor"]],
				"paint": [
					"line-color": "#E1E4E6",
					"line-width": ["base": 1.25, "stops": [[12, 1.3], [22, 20]]]
				]
			]
		]
	}

	private func makeMediumRoadLayers() -> [[String: Any]] {
		[
			[
				"id": "road_tertiary_secondary_casing",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"filter": ["all", ["==", "$type", "LineString"], ["in", "class", "secondary", "tertiary"]],
				"paint": [
					"line-color": "#C7CCD0",
					"line-width": ["base": 1.25, "stops": [[10, 2.4], [22, 30]]]
				]
			],
			[
				"id": "road_tertiary_secondary",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"filter": ["all", ["==", "$type", "LineString"], ["in", "class", "secondary", "tertiary"]],
				"paint": [
					"line-color": "#E1E4E6",
					"line-width": ["base": 1.25, "stops": [[10, 2], [22, 26]]]
				]
			],
			[
				"id": "road_primary_casing",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"filter": ["all", ["==", "$type", "LineString"], ["==", "class", "primary"]],
				"paint": [
					"line-color": "#BFC5CA",
					"line-width": ["base": 1.2, "stops": [[8, 3], [22, 40]]]
				]
			],
			[
				"id": "road_primary",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"filter": ["all", ["==", "$type", "LineString"], ["==", "class", "primary"]],
				"paint": [
					"line-color": "#E1E4E6",
					"line-width": ["base": 1.2, "stops": [[8, 2.4], [22, 36]]]
				]
			]
		]
	}

	private func makeHighwayLayers() -> [[String: Any]] {
		[
			[
				"id": "road_trunk_casing",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"filter": ["all", ["==", "$type", "LineString"], ["==", "class", "trunk"]],
				"paint": [
					"line-color": "#B8BFC5",
					"line-width": ["base": 1.2, "stops": [[8, 3.2], [22, 44]]]
				]
			],
			[
				"id": "road_trunk",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"filter": ["all", ["==", "$type", "LineString"], ["==", "class", "trunk"]],
				"paint": [
					"line-color": "#7C9AB7",
					"line-width": ["base": 1.2, "stops": [[8, 2.8], [22, 40]]]
				]
			],
			[
				"id": "road_motorway_casing",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"filter": ["all", ["==", "$type", "LineString"], ["==", "class", "motorway"]],
				"paint": [
					"line-color": "#B0B8BF",
					"line-width": ["base": 1.2, "stops": [[8, 3.6], [22, 50]]]
				]
			],
			[
				"id": "road_motorway",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"filter": ["all", ["==", "$type", "LineString"], ["==", "class", "motorway"]],
				"paint": [
					"line-color": "#FFF7C0",
					"line-width": ["base": 1.2, "stops": [[8, 3.2], [22, 46]]]
				]
			],
			[
				"id": "road_ramp_casing",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"filter": ["all", ["==", "$type", "LineString"], ["==", "ramp", 1]],
				"paint": [
					"line-color": "#BFC6CC",
					"line-width": ["base": 1.2, "stops": [[12, 2.2], [22, 24]]]
				]
			],
			[
				"id": "road_ramp",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"filter": ["all", ["==", "$type", "LineString"], ["==", "ramp", 1]],
				"paint": [
					"line-color": "rgba(224, 224, 224, 1)",
					"line-width": ["base": 1.2, "stops": [[12, 1.8], [22, 20]]]
				]
			],
			[
				"id": "road_roundabout",
				"type": "line",
				"source": "openmaptiles",
				"source-layer": "transportation",
				"filter": ["all", ["==", "$type", "LineString"], ["==", "junction", "roundabout"]],
				"layout": ["line-cap": "round", "line-join": "round"],
				"paint": [
					"line-color": "#FFF9DA",
					"line-width": ["base": 1.2, "stops": [[10, 3], [22, 36]]]
				]
			]
		]
	}

	private func makeRoadLabelLayer() -> [String: Any] {
		[
			"id": "road_major_label",
			"type": "symbol",
			"source": "openmaptiles",
			"source-layer": "transportation_name",
			"minzoom": 10,
			"layout": [
				"symbol-placement": "line",
				"text-field": ["coalesce", ["get", "name:km"], ["get", "name"], ["get", "name:latin"], ["get", "name:en"]],
				"text-font": ["Noto Sans Regular"],
				"text-size": ["base": 1.1, "stops": [[10, 12], [22, 20]]]
			],
			"paint": [
				"text-color": "#55595E",
				"text-halo-color": "#FFFFFF",
				"text-halo-width": 1.6
			]
		]
	}

	private func makeProvinceBoundaryLayer() -> [String: Any] {
		[
			"id": "boundary_province",
			"type": "line",
			"source": "openmaptiles",
			"source-layer": "boundary",
			"minzoom": 5,
			"filter": ["all", [">", "admin_level", 2], ["<=", "admin_level", 4]],
			"layout": ["line-join": "round", "line-cap": "round"],
			"paint": [
				"line-color": "rgba(120, 132, 146, 0.45)",
				"line-width": ["interpolate", ["linear"], ["zoom"], 5, 0.5, 9, 1, 14, 1.8],
				"line-dasharray": [3, 2]
			]
		]
	}

	private func makeCityBoundaryLayer() -> [String: Any] {
		[
			"id": "boundary_city",
			"type": "line",
			"source": "openmaptiles",
			"source-layer": "boundary",
			"minzoom": 8,
			"filter": ["all", [">", "admin_level", 4], ["<=", "admin_level", 8]],
			"layout": ["line-join": "round", "line-cap": "round"],
			"paint": [
				"line-color": "rgba(150, 160, 170, 0.35)",
				"line-width": ["interpolate", ["linear"], ["zoom"], 8, 0.4, 12, 0.8, 15, 1.3],
				"line-dasharray": [2, 2]
			]
		]
	}

	private func makeDistrictBoundaryLayer() -> [String: Any] {
		[
			"id": "runtime_boundary_district",
			"type": "line",
			"source": "openmaptiles",
			"source-layer": "boundary",
			"minzoom": 9,
			"filter": ["all", [">", "admin_level", 5], ["<=", "admin_level", 7]],
			"layout": ["line-join": "round", "line-cap": "round"],
			"paint": [
				"line-color": "rgba(175, 182, 190, 0.3)",
				"line-width": ["interpolate", ["linear"], ["zoom"], 9, 0.3, 12, 0.55, 15, 0.9],
				"line-dasharray": [1.5, 2]
			]
		]
	}

	private func makeProvinceLabelLayer() -> [String: Any] {
		[
			"id": "place_label_province",
			"type": "symbol",
			"source": "openmaptiles",
			"source-layer": "place",
			"minzoom": 4,
			"filter": ["==", "class", "state"],
			"layout": [
				"text-field": ["coalesce", ["get", "name:km"], ["get", "name"], ["get", "name:latin"], ["get", "name:en"]],
				"text-font": ["Noto Sans Regular"],
				"text-size": ["stops": [[4, 11], [8, 15], [12, 18]]],
				"text-padding": 4,
				"text-letter-spacing": 0.03
			],
			"paint": [
				"text-color": "#5A6470",
				"text-halo-color": "#FFFFFF",
				"text-halo-width": 1.2,
				"text-opacity": 0.9
			]
		]
	}

	private func makeDistrictLabelLayer() -> [String: Any] {
		[
			"id": "place_label_district",
			"type": "symbol",
			"source": "openmaptiles",
			"source-layer": "place",
			"minzoom": 7,
			"filter": ["in", "class", "county", "town"],
			"layout": [
				"text-field": ["coalesce", ["get", "name:km"], ["get", "name"], ["get", "name:latin"], ["get", "name:en"]],
				"text-font": ["Noto Sans Regular"],
				"text-size": ["stops": [[7, 10], [10, 13], [13, 15]]],
				"text-padding": 3,
				"text-letter-spacing": 0.02
			],
			"paint": [
				"text-color": "#6B7480",
				"text-halo-color": "#FFFFFF",
				"text-halo-width": 1.1,
				"text-opacity": 0.88
			]
		]
	}

	private func makeCityLabelLayer() -> [String: Any] {
		[
			"id": "place_label_city",
			"type": "symbol",
			"source": "openmaptiles",
			"source-layer": "place",
			"filter": ["==", "class", "city"],
			"layout": [
				"text-field": ["coalesce", ["get", "name:km"], ["get", "name"], ["get", "name:latin"], ["get", "name:en"]],
				"text-font": ["Noto Sans Regular"],
				"text-size": ["stops": [[5, 13], [10, 19]]],
				"text-padding": 4
			],
			"paint": [
				"text-color": "#21272E",
				"text-halo-color": "#FFFFFF",
				"text-halo-width": 1.4,
				"text-opacity": 0.9
			]
		]
	}

	private func makePrivateBuildingLayer() -> [String: Any] {
		[
			"id": "runtime_building_private",
			"type": "fill",
			"source": "openmaptiles",
			"source-layer": "building",
			"filter": ["!=", "aeroway", "terminal"],
			"paint": [
				"fill-color": "#F9F6EF",
				"fill-outline-color": "#E3E0D9"
			]
		]
	}

	private func makePublicBuildingLayer() -> [String: Any] {
		[
			"id": "terminal-building",
			"type": "fill",
			"source": "openmaptiles",
			"source-layer": "building",
			"filter": ["==", "aeroway", "terminal"],
			"paint": [
				"fill-color": "#b8c1cc",
				"fill-opacity": 0.9
			]
		]
	}
}

extension MapCustomCheckListViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		sections.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		sections[section].count
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		Section(rawValue: section)?.title
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: MapStyleOptionCell.reuseIdentifier, for: indexPath) as? MapStyleOptionCell else {
			return UITableViewCell()
		}
		let option = sections[indexPath.section][indexPath.row]
		cell.configure(with: option) { [weak self] isEnabled in
			self?.updateOption(at: indexPath, isEnabled: isEnabled)
		}
		return cell
	}
}

extension MapCustomCheckListViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let nextValue = !sections[indexPath.section][indexPath.row].isEnabled
		updateOption(at: indexPath, isEnabled: nextValue)
		tableView.reloadRows(at: [indexPath], with: .automatic)
	}
	
	
}
