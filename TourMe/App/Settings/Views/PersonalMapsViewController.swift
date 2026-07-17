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
					return "map_features".localized()
				case .roads:
					return "road_network".localized()
				case .labels:
					return "map_labels".localized()
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

	private struct StyleSnapshot: Equatable {
		let selectedFeatureIDs: Set<String>
		let featureColorHexByID: [String: String]
	}

	private final class MapFeatureCell: UITableViewCell {

		private let checkBox = CheckBox()
		private let titleLabel = UILabel()
		private let colorButton = UIButton(type: .system)
		var onColorTap: (() -> Void)?

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

			colorButton.layer.cornerRadius = 12
			colorButton.layer.borderWidth = 1
			colorButton.layer.borderColor = UIColor.separator.cgColor
			colorButton.translatesAutoresizingMaskIntoConstraints = false
			colorButton.addTarget(self, action: #selector(didTapColor), for: .touchUpInside)

			contentView.addSubview(checkBox)
			contentView.addSubview(titleLabel)
			contentView.addSubview(colorButton)

			NSLayoutConstraint.activate([
				checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
				checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
				checkBox.widthAnchor.constraint(equalToConstant: 24),
				checkBox.heightAnchor.constraint(equalToConstant: 24),

				titleLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 14),
				titleLabel.trailingAnchor.constraint(equalTo: colorButton.leadingAnchor, constant: -14),
				titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

				colorButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
				colorButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
				colorButton.widthAnchor.constraint(equalToConstant: 24),
				colorButton.heightAnchor.constraint(equalToConstant: 24)
			])
		}

		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		func configure(title: String, isSelected: Bool, color: UIColor) {
			titleLabel.text = title
			checkBox.isChecked = isSelected
			colorButton.backgroundColor = color
		}

		override func prepareForReuse() {
			super.prepareForReuse()
			onColorTap = nil
		}

		@objc private func didTapColor() {
			onColorTap?()
		}
	}

	private let userDefaultsKey = "personalMapSelectedFeatureIDs"
	private let userDefaultsColorsKey = "personalMapFeatureColors"

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

	private lazy var zoomControl: UIStackView = {
		let zoomInButton = makeZoomButton(systemName: "plus", action: #selector(zoomInMap))
		let zoomOutButton = makeZoomButton(systemName: "minus", action: #selector(zoomOutMap))
		let separator = UIView()
		separator.backgroundColor = .separator
		separator.translatesAutoresizingMaskIntoConstraints = false

		let stackView = UIStackView(arrangedSubviews: [zoomInButton, separator, zoomOutButton])
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 0
		stackView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.86)
		stackView.layer.cornerRadius = 12
		stackView.layer.borderWidth = 1
		stackView.layer.borderColor = UIColor.separator.cgColor
		stackView.layer.masksToBounds = true
		stackView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			separator.widthAnchor.constraint(equalToConstant: 22),
			separator.heightAnchor.constraint(equalToConstant: 1)
		])

		return stackView
	}()

	private lazy var undoButton: UIButton = makeHeaderActionButton(imageName: "undo", action: #selector(undoColorChange), isEnabled: false)
	private lazy var redoButton: UIButton = makeHeaderActionButton(imageName: "redo", action: #selector(redoColorChange), isEnabled: false)

	private lazy var undoRedoControl: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [undoButton, redoButton])
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.spacing = 6
		stackView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.86)
		stackView.layer.cornerRadius = 12
		stackView.layer.borderWidth = 1
		stackView.layer.borderColor = UIColor.separator.cgColor
		stackView.layer.masksToBounds = true
		stackView.layoutMargins = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	private lazy var features: [MapFeature] = [
		MapFeature(id: "land", title: "land_use".localized(), section: .base) { layerID, sourceLayer in
			layerID.contains("landuse") || sourceLayer == "landuse"
		},
		MapFeature(id: "nature", title: "parks_and_nature".localized(), section: .base) { layerID, sourceLayer in
			layerID.contains("landcover") || layerID.contains("park") || sourceLayer == "landcover"
		},
		MapFeature(id: "water", title: "water".localized(), section: .base) { layerID, sourceLayer in
			layerID.contains("water") || sourceLayer == "water"
		},
		MapFeature(id: "buildings", title: "buildings".localized(), section: .base) { layerID, sourceLayer in
			layerID.contains("building") || sourceLayer == "building"
		},
		MapFeature(id: "minor_roads", title: "minor_roads".localized(), section: .roads) { layerID, sourceLayer in
			sourceLayer == "transportation" && layerID.contains("minor")
		},
		MapFeature(id: "main_roads", title: "main_roads".localized(), section: .roads) { layerID, sourceLayer in
			sourceLayer == "transportation" && (layerID.contains("primary") || layerID.contains("secondary") || layerID.contains("tertiary") || layerID.contains("trunk"))
		},
		MapFeature(id: "road_labels", title: "road_labels".localized(), section: .labels) { layerID, sourceLayer in
			(sourceLayer == "transportation_name" || layerID.contains("road")) && layerID.contains("label")
		},
		MapFeature(id: "place_labels", title: "place_labels".localized(), section: .labels) { layerID, sourceLayer in
			layerID.contains("place") || sourceLayer == "place"
		},
		MapFeature(id: "poi_labels", title: "poi_labels".localized(), section: .labels) { layerID, sourceLayer in
			layerID.contains("poi") || sourceLayer == "poi"
		}
	]

	private lazy var selectedFeatureIDs: Set<String> = loadSelectedFeatureIDs()
	private lazy var featureColorHexByID: [String: String] = loadFeatureColors()
	private lazy var defaultFeatureColorByID: [String: UIColor] = loadDefaultFeatureColors()
	private var colorEditingFeature: MapFeature?
	private var colorEditingOriginalSnapshot: StyleSnapshot?
	private var undoStyleHistory: [StyleSnapshot] = []
	private var redoStyleHistory: [StyleSnapshot] = []
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
		view.addSubview(zoomControl)
		view.addSubview(undoRedoControl)
		undoRedoControl.isHidden = true
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
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			zoomControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			zoomControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
			zoomControl.widthAnchor.constraint(equalToConstant: 40),

			undoRedoControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			undoRedoControl.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16),
			undoRedoControl.heightAnchor.constraint(equalToConstant: 40)
		])
	}

	override func viewDidLoad() {
		super.viewDidLoad()
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
		let title = isEditingStyle ? "save".localized() : "edit".localized()
		let action = isEditingStyle ? #selector(saveStyle) : #selector(startEditingStyle)
		let editItem = UIBarButtonItem(title: title, style: .plain, target: self, action: action)
		let resetItem = UIBarButtonItem(title: "reset".localized(), style: .plain, target: self, action: #selector(confirmResetStyle))

		[editItem, resetItem].forEach { item in
			item.tintColor = .label
			item.setTitleTextAttributes(barButtonAttributes, for: .normal)
			item.setTitleTextAttributes(barButtonAttributes, for: .highlighted)
		}
		navigationItem.rightBarButtonItems = [editItem, resetItem]
	}

	private func makeZoomButton(systemName: String, action: Selector) -> UIButton {
		let button = UIButton(type: .custom)
		button.setImage(UIImage(systemName: systemName), for: .normal)
		button.tintColor = .label
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: action, for: .touchUpInside)
		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalToConstant: 40),
			button.heightAnchor.constraint(equalToConstant: 44)
		])
		return button
	}

	private func makeHeaderActionButton(imageName: String, action: Selector, isEnabled: Bool) -> UIButton {
		let button = UIButton(type: .custom)
		let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
		button.setImage(image, for: .normal)
		button.tintColor = isEnabled ? .label : .secondaryLabel
		button.isEnabled = isEnabled
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: action, for: .touchUpInside)
		NSLayoutConstraint.activate([
			button.heightAnchor.constraint(equalToConstant: 28),
			button.widthAnchor.constraint(equalToConstant: 32)
		])
		return button
	}

	private func reloadMapFeaturesHeader() {
		guard isEditingStyle else { return }
		updateUndoRedoButtons()
	}

	private func updateUndoRedoButtons() {
		undoButton.isEnabled = !undoStyleHistory.isEmpty
		undoButton.tintColor = undoButton.isEnabled ? .label : .secondaryLabel
		redoButton.isEnabled = !redoStyleHistory.isEmpty
		redoButton.tintColor = redoButton.isEnabled ? .label : .secondaryLabel
	}

	@objc private func closeScreen() {
		dismiss(animated: true)
	}

	@objc private func zoomInMap() {
		mapView.setZoomLevel(min(mapView.zoomLevel + 1, 22), animated: true)
	}

	@objc private func zoomOutMap() {
		mapView.setZoomLevel(max(mapView.zoomLevel - 1, 0), animated: true)
	}

	@objc private func startEditingStyle() {
		isEditingStyle = true
		updateRightBarButton()
		mapFullScreenBottomConstraint.isActive = false
		mapEditHeightConstraint.isActive = true
		undoRedoControl.isHidden = false
		tableView.isHidden = false
		updateUndoRedoButtons()

		UIView.animate(withDuration: 0.25) {
			self.view.layoutIfNeeded()
		}
	}

	@objc private func saveStyle() {
		UserDefaults.standard.set(Array(selectedFeatureIDs), forKey: userDefaultsKey)
		UserDefaults.standard.set(featureColorHexByID, forKey: userDefaultsColorsKey)
		dismiss(animated: true)
	}

	@objc private func confirmResetStyle() {
		let alert = UIAlertController(title: "reset_map_style_title".localized(), message: "reset_map_style_message".localized(), preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel))
		alert.addAction(UIAlertAction(title: "reset".localized(), style: .destructive) { [weak self] _ in
			self?.resetStyle()
		})
		present(alert, animated: true)
	}

	private func resetStyle() {
		selectedFeatureIDs = Set(features.map(\.id))
		undoStyleHistory.removeAll()
		redoStyleHistory.removeAll()
		featureColorHexByID.removeAll()
		UserDefaults.standard.removeObject(forKey: userDefaultsKey)
		UserDefaults.standard.removeObject(forKey: userDefaultsColorsKey)
		tableView.reloadData()
		applySelectedStyle()
	}

	private func editColor(for feature: MapFeature) {
		colorEditingFeature = feature
		colorEditingOriginalSnapshot = currentStyleSnapshot()
		let picker = UIColorPickerViewController()
		picker.delegate = self
		picker.supportsAlpha = false
		picker.selectedColor = color(for: feature)
		present(picker, animated: true)
	}

	private func updateColor(_ color: UIColor, for feature: MapFeature, recordsUndo: Bool = true) {
		let previousSnapshot = currentStyleSnapshot()
		featureColorHexByID[feature.id] = color.hexString
		if recordsUndo && previousSnapshot != currentStyleSnapshot() {
			undoStyleHistory.append(previousSnapshot)
			redoStyleHistory.removeAll()
			reloadMapFeaturesHeader()
		}
		applySelectedStyle()
		tableView.reloadData()
	}

	@objc private func undoColorChange() {
		guard let previousSnapshot = undoStyleHistory.popLast() else { return }
		redoStyleHistory.append(currentStyleSnapshot())
		restoreStyleSnapshot(previousSnapshot)
		reloadMapFeaturesHeader()
		applySelectedStyle()
		tableView.reloadData()
	}

	@objc private func redoColorChange() {
		guard let nextSnapshot = redoStyleHistory.popLast() else { return }
		undoStyleHistory.append(currentStyleSnapshot())
		restoreStyleSnapshot(nextSnapshot)
		reloadMapFeaturesHeader()
		applySelectedStyle()
		tableView.reloadData()
	}

	private func currentStyleSnapshot() -> StyleSnapshot {
		StyleSnapshot(selectedFeatureIDs: selectedFeatureIDs, featureColorHexByID: featureColorHexByID)
	}

	private func restoreStyleSnapshot(_ snapshot: StyleSnapshot) {
		selectedFeatureIDs = snapshot.selectedFeatureIDs
		featureColorHexByID = snapshot.featureColorHexByID
	}

	private func features(in section: Section) -> [MapFeature] {
		features.filter { $0.section == section }
	}

	private func color(for feature: MapFeature) -> UIColor {
		if let hex = featureColorHexByID[feature.id], let color = UIColor(hexString: hex) {
			return color
		}
		return defaultFeatureColorByID[feature.id] ?? defaultColor(for: feature)
	}

	private func defaultColor(for feature: MapFeature) -> UIColor {
		switch feature.id {
			case "land":
				return UIColor(red: 0.86, green: 0.79, blue: 0.66, alpha: 1)
			case "nature":
				return UIColor(red: 0.48, green: 0.73, blue: 0.39, alpha: 1)
			case "water":
				return UIColor(red: 0.35, green: 0.67, blue: 0.90, alpha: 1)
			case "buildings":
				return UIColor(red: 0.78, green: 0.74, blue: 0.68, alpha: 1)
			case "minor_roads":
				return UIColor(red: 0.76, green: 0.78, blue: 0.80, alpha: 1)
			case "main_roads":
				return UIColor(red: 0.98, green: 0.70, blue: 0.35, alpha: 1)
			case "road_labels", "place_labels", "poi_labels":
				return .label
			default:
				return .primary
		}
	}

	private func toggleFeature(_ feature: MapFeature) {
		let previousSnapshot = currentStyleSnapshot()
		if selectedFeatureIDs.contains(feature.id) {
			selectedFeatureIDs.remove(feature.id)
		} else {
			selectedFeatureIDs.insert(feature.id)
		}
		if previousSnapshot != currentStyleSnapshot() {
			undoStyleHistory.append(previousSnapshot)
			redoStyleHistory.removeAll()
			reloadMapFeaturesHeader()
		}
		applySelectedStyle()
	}

	private func loadSelectedFeatureIDs() -> Set<String> {
		guard let storedIDs = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] else {
			return Set(features.map(\.id))
		}
		return Set(storedIDs)
	}

	private func loadFeatureColors() -> [String: String] {
		UserDefaults.standard.dictionary(forKey: userDefaultsColorsKey) as? [String: String] ?? [:]
	}

	private func loadDefaultFeatureColors() -> [String: UIColor] {
		guard let stylePath = Bundle.main.path(forResource: "map-style-default", ofType: "json"),
			  let styleData = try? Data(contentsOf: URL(fileURLWithPath: stylePath)),
			  let styleJSON = try? JSONSerialization.jsonObject(with: styleData) as? [String: Any],
			  let layers = styleJSON["layers"] as? [[String: Any]] else {
			return [:]
		}

		var colors: [String: UIColor] = [:]
		for layer in layers {
			guard let layerID = layer["id"] as? String,
				  let paint = layer["paint"] as? [String: Any] else { continue }

			let sourceLayer = (layer["source-layer"] as? String)?.lowercased()
			let normalizedLayerID = layerID.lowercased()
			for feature in features where colors[feature.id] == nil && feature.layerMatcher(normalizedLayerID, sourceLayer) {
				for key in paintColorKeys(for: layer["type"] as? String) {
					if let colorString = paint[key] as? String, let color = UIColor(styleColorString: colorString) {
						colors[feature.id] = color
						break
					}
				}
			}
		}
		return colors
	}

	private func paintColorKeys(for layerType: String?) -> [String] {
		switch layerType {
			case "background":
				return ["background-color"]
			case "fill":
				return ["fill-color", "fill-outline-color"]
			case "line":
				return ["line-color"]
			case "symbol":
				return ["text-color", "icon-color"]
			case "circle":
				return ["circle-color"]
			default:
				return []
		}
	}

	private func applySelectedStyle() {
		guard let stylePath = Bundle.main.path(forResource: "map-style-default", ofType: "json"),
			  let styleData = try? Data(contentsOf: URL(fileURLWithPath: stylePath)),
			  var styleJSON = try? JSONSerialization.jsonObject(with: styleData) as? [String: Any],
			  let layers = styleJSON["layers"] as? [[String: Any]] else {
			return
		}

		let filteredLayers = layers.compactMap { layer -> [String: Any]? in
			guard let layerID = layer["id"] as? String else { return layer }
			let sourceLayer = (layer["source-layer"] as? String)?.lowercased()
			let normalizedLayerID = layerID.lowercased()
			let matchedFeatures = features.filter { $0.layerMatcher(normalizedLayerID, sourceLayer) }

			guard !matchedFeatures.isEmpty else { return layer }
			guard let selectedFeature = matchedFeatures.first(where: { selectedFeatureIDs.contains($0.id) }) else { return nil }

				guard let customColorHex = featureColorHexByID[selectedFeature.id] else { return layer }

				var updatedLayer = layer
				var paint = updatedLayer["paint"] as? [String: Any] ?? [:]
				for key in paintColorKeys(for: updatedLayer["type"] as? String) where paint[key] != nil {
					paint[key] = customColorHex
				}
				updatedLayer["paint"] = paint
				return updatedLayer
		}

		styleJSON["layers"] = filteredLayers

		guard let updatedData = try? JSONSerialization.data(withJSONObject: styleJSON, options: [.prettyPrinted]),
			  let updatedStyle = String(data: updatedData, encoding: .utf8) else {
			return
		}

		mapView.applyStyleJSON(updatedStyle, cacheKey: "personal-map-\(selectedFeatureIDs.sorted().joined(separator: "-"))-\(featureColorHexByID.sorted { $0.key < $1.key }.map { "\($0.key)-\($0.value)" }.joined(separator: "-"))")
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
		cell.configure(title: feature.title, isSelected: selectedFeatureIDs.contains(feature.id), color: color(for: feature))
		cell.onColorTap = { [weak self] in
			self?.editColor(for: feature)
		}
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

extension PersonalMapsViewController: UIColorPickerViewControllerDelegate {

	func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
		guard let feature = colorEditingFeature else { return }
		updateColor(viewController.selectedColor, for: feature, recordsUndo: false)
	}

	func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
		guard let feature = colorEditingFeature else { return }
		let originalSnapshot = colorEditingOriginalSnapshot
		updateColor(viewController.selectedColor, for: feature, recordsUndo: false)
		colorEditingFeature = nil
		colorEditingOriginalSnapshot = nil

		if let originalSnapshot, originalSnapshot != currentStyleSnapshot() {
			undoStyleHistory.append(originalSnapshot)
			redoStyleHistory.removeAll()
			reloadMapFeaturesHeader()
		}
	}
}

private extension UIColor {

	convenience init?(styleColorString: String) {
		let string = styleColorString.trimmingCharacters(in: .whitespacesAndNewlines)
		if string.hasPrefix("#") {
			self.init(hexString: string)
			return
		}

		let lowercasedString = string.lowercased()
		guard lowercasedString.hasPrefix("rgb"),
			  let openParenthesis = lowercasedString.firstIndex(of: "("),
			  let closeParenthesis = lowercasedString.firstIndex(of: ")") else {
			return nil
		}

		let componentString = lowercasedString[lowercasedString.index(after: openParenthesis)..<closeParenthesis]
		let components = componentString
			.split(separator: ",")
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

		guard components.count >= 3,
			  let red = Double(components[0]),
			  let green = Double(components[1]),
			  let blue = Double(components[2]) else {
			return nil
		}

		let alpha = components.count > 3 ? Double(components[3]) ?? 1 : 1
		self.init(
			red: CGFloat(red / 255),
			green: CGFloat(green / 255),
			blue: CGFloat(blue / 255),
			alpha: CGFloat(alpha)
		)
	}

	convenience init?(hexString: String) {
		var string = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		if string.hasPrefix("#") {
			string.removeFirst()
		}
		if string.count == 3 {
			string = string.map { "\($0)\($0)" }.joined()
		}
		guard string.count == 6, let value = Int(string, radix: 16) else { return nil }
		self.init(
			red: CGFloat((value >> 16) & 0xFF) / 255.0,
			green: CGFloat((value >> 8) & 0xFF) / 255.0,
			blue: CGFloat(value & 0xFF) / 255.0,
			alpha: 1
		)
	}

	var hexString: String {
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
	}
}
