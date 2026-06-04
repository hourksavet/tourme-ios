//
//  MapsViewController.swift
//  TourMe
//
//  Created by Savet on 3/7/25.
//

import UIKit
import MapLibre
import SVProgressHUD


private struct LocationViewModel {
	var isUserLocation: Bool = false
	var title: String = ""
	var coordinate: CLLocationCoordinate2D?
	var distance: Int = 0
}

private enum EditRouteType {
	case origin
	case destination
}

class MapsViewController: UIViewController {
	
	private lazy var mapView: ToureMeMapView = {
		let mapV = ToureMeMapView()
		mapV.showsUserLocation = true
		mapV.showsUserHeadingIndicator = true
		mapV.userTrackingMode = .follow
		mapV.layoutMargins = .zero
		mapV.isRotateEnabled = false
		mapV.delegate = self
		mapV.automaticallyAdjustsContentInset = false
		mapV.translatesAutoresizingMaskIntoConstraints = false
		return mapV
	}()
	
	private lazy var bkStatusView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var locationBtn: UIButton = {
		let button = UIButton(type: .system)
		button.tintColor = .primary
		button.backgroundColor = .white
		button.alpha = 0.9
		button.setImage(UIImage(systemName: "location.fill"), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(onClickLocationBtn), for: .touchUpInside)
		return button
	}()
	
	private lazy var routeSetupContentView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.alpha = 0.96
		view.clipsToBounds = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var routeSetupHeaderView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var routeSetupExpandedView: UIView = {
		let view = UIView()
		view.isHidden = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var chooseOnMapButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Choose on map", for: .normal)
		button.semanticContentAttribute = .forceRightToLeft
		button.contentHorizontalAlignment = .leading
		button.tintColor = .primary
		button.setTitleColor(.primary, for: .normal)
		button.titleLabel?.font = .defaultMedium(size: 17)
		button.addTarget(self, action: #selector(onChooseOnMap), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	private lazy var currentLocationButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Current location", for: .normal)
		button.contentHorizontalAlignment = .leading
		button.tintColor = .primary
		button.setTitleColor(.primary, for: .normal)
		button.titleLabel?.font = .defaultMedium(size: 17)
		button.addTarget(self, action: #selector(onUseCurrentLocation), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	private lazy var suggestionTableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.backgroundColor = .clear
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 0)
		tableView.showsVerticalScrollIndicator = false
		tableView.isScrollEnabled = false
		tableView.rowHeight = 96
		tableView.register(RoutePlaceSuggestionCell.self)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()

	private lazy var routeOriginIconView: UIImageView = {
		let imageView = UIImageView(image: UIImage(systemName: "circle.inset.filled"))
		imageView.tintColor = .primary
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private lazy var routeConnectorStackView: UIStackView = {
		let stack = UIStackView(arrangedSubviews: (0..<4).map { _ in makeRouteConnectorDot() })
		stack.axis = .vertical
		stack.alignment = .center
		stack.distribution = .equalSpacing
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	private lazy var routeDestinationIconView: UIImageView = {
		let imageView = UIImageView(image: UIImage(named: "ic_marker"))
		imageView.tintColor = .systemRed
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private lazy var originTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Search origin"
		textField.font = .defaultMedium(size: 17)
		textField.textColor = .primary
		textField.tintColor = .primary
		textField.returnKeyType = .done
		textField.clearButtonMode = .whileEditing
		textField.borderStyle = .none
		textField.layer.cornerRadius = 10
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		return textField
	}()

	private lazy var routeSetupDividerView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var destinationTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Search place"
		textField.font = .defaultMedium(size: 17)
		textField.textColor = .black
		textField.tintColor = .primary
		textField.returnKeyType = .done
		textField.clearButtonMode = .whileEditing
		textField.borderStyle = .none
		textField.layer.cornerRadius = 10
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		return textField
	}()

	private lazy var swapRouteButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(named: "switch_location"), for: .normal)
		button.tintColor = .black
		button.addTarget(self, action: #selector(onSwapRouteDirection), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var zoomControlView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.alpha = 0.9
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var zoomInBtn: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "plus"), for: .normal)
		button.tintColor = .primary
		button.addTarget(self, action: #selector(onZoomIn), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var zoomOutBtn: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "minus"), for: .normal)
		button.tintColor = .primary
		button.addTarget(self, action: #selector(onZoomOut), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var statusEffectView: UIVisualEffectView = {
		let effect = UIBlurEffect(style: .systemMaterialLight)
		let view = UIVisualEffectView(effect: effect)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let statusFadeMask = CAGradientLayer()
	
	private var originLoModel: LocationViewModel? {
		didSet {
			onUpdateOriginModel()
		}
	}
	
	private var destinationLoModel: LocationViewModel? {
		didSet {
			onUpdateDestinationModel()
		}
	}
	
	private var currentLocation: CLLocation?
	
	// To update route progress ongoing tour
	private var previousCoordinates: [CLLocationCoordinate2D] = []
	private var nextCoordinates: [CLLocationCoordinate2D] = []
	
	private var allPlaceModels: [PlaceListModel] = []
	private var filteredPlaceModels: [PlaceListModel] = []
	
	private var editingRouteType: EditRouteType = .destination
	
	private var routeSetupExpandedHeightAnchor: NSLayoutConstraint?
	private var routeSetupBottomAnchor: NSLayoutConstraint?
	
	private var isChangingMapPitch: Bool = false
	
	private var locationState: LocationMode = .focusing {
		didSet {
			updateLocationButton()
		}
	}

	private func makeRouteConnectorDot() -> UIView {
		let dotView = UIView()
		dotView.backgroundColor = .primary
		dotView.layer.cornerRadius = 2
		dotView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			dotView.widthAnchor.constraint(equalToConstant: 4),
			dotView.heightAnchor.constraint(equalToConstant: 4)
		])
		return dotView
	}
	
	override func loadView() {
		super.loadView()
		view.addSubview(mapView)
		view.addSubview(bkStatusView)
		view.addSubview(locationBtn)
		view.addSubview(zoomControlView)
		view.addSubview(routeSetupContentView)
		bkStatusView.addSubview(statusEffectView)
		
		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: view.topAnchor),
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			bkStatusView.topAnchor.constraint(equalTo: view.topAnchor),
			bkStatusView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			bkStatusView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			bkStatusView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

			statusEffectView.topAnchor.constraint(equalTo: bkStatusView.topAnchor),
			statusEffectView.leadingAnchor.constraint(equalTo: bkStatusView.leadingAnchor),
			statusEffectView.trailingAnchor.constraint(equalTo: bkStatusView.trailingAnchor),
			statusEffectView.bottomAnchor.constraint(equalTo: bkStatusView.bottomAnchor),
			
			locationBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
			locationBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			locationBtn.widthAnchor.constraint(equalToConstant: 50),
			locationBtn.heightAnchor.constraint(equalToConstant: 50),

			zoomControlView.widthAnchor.constraint(equalToConstant: 50),
			zoomControlView.bottomAnchor.constraint(equalTo: locationBtn.topAnchor, constant: -10),
			zoomControlView.trailingAnchor.constraint(equalTo: locationBtn.trailingAnchor),
			
			routeSetupContentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			routeSetupContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			routeSetupContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
		])
		
		routeSetupContentView.addSubview(routeSetupHeaderView)
		routeSetupContentView.addSubview(routeSetupExpandedView)
		routeSetupHeaderView.addSubview(routeOriginIconView)
		routeSetupHeaderView.addSubview(routeConnectorStackView)
		routeSetupHeaderView.addSubview(routeDestinationIconView)
		routeSetupHeaderView.addSubview(originTextField)
		routeSetupHeaderView.addSubview(routeSetupDividerView)
		routeSetupHeaderView.addSubview(destinationTextField)
		routeSetupHeaderView.addSubview(swapRouteButton)
		routeSetupExpandedView.addSubview(currentLocationButton)
		routeSetupExpandedView.addSubview(chooseOnMapButton)
		routeSetupExpandedView.addSubview(suggestionTableView)

		let leftQuickActionGuide = UILayoutGuide()
		let rightQuickActionGuide = UILayoutGuide()
		routeSetupExpandedView.addLayoutGuide(leftQuickActionGuide)
		routeSetupExpandedView.addLayoutGuide(rightQuickActionGuide)

		routeSetupExpandedHeightAnchor = routeSetupExpandedView.heightAnchor.constraint(equalToConstant: 0)
		routeSetupExpandedHeightAnchor?.isActive = true
		routeSetupBottomAnchor = routeSetupContentView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
		routeSetupBottomAnchor?.isActive = true

		NSLayoutConstraint.activate([
			routeSetupHeaderView.topAnchor.constraint(equalTo: routeSetupContentView.topAnchor),
			routeSetupHeaderView.leadingAnchor.constraint(equalTo: routeSetupContentView.leadingAnchor),
			routeSetupHeaderView.trailingAnchor.constraint(equalTo: routeSetupContentView.trailingAnchor),
			routeSetupHeaderView.heightAnchor.constraint(equalToConstant: 120),

			routeSetupExpandedView.topAnchor.constraint(equalTo: routeSetupHeaderView.bottomAnchor),
			routeSetupExpandedView.leadingAnchor.constraint(equalTo: routeSetupContentView.leadingAnchor),
			routeSetupExpandedView.trailingAnchor.constraint(equalTo: routeSetupContentView.trailingAnchor),
			routeSetupExpandedView.bottomAnchor.constraint(equalTo: routeSetupContentView.bottomAnchor),

			leftQuickActionGuide.topAnchor.constraint(equalTo: routeSetupExpandedView.topAnchor),
			leftQuickActionGuide.leadingAnchor.constraint(equalTo: routeSetupExpandedView.leadingAnchor),
			leftQuickActionGuide.trailingAnchor.constraint(equalTo: routeSetupExpandedView.centerXAnchor),
			leftQuickActionGuide.heightAnchor.constraint(equalToConstant: 42),

			rightQuickActionGuide.topAnchor.constraint(equalTo: routeSetupExpandedView.topAnchor),
			rightQuickActionGuide.leadingAnchor.constraint(equalTo: routeSetupExpandedView.centerXAnchor),
			rightQuickActionGuide.trailingAnchor.constraint(equalTo: routeSetupExpandedView.trailingAnchor),
			rightQuickActionGuide.heightAnchor.constraint(equalToConstant: 42),

			currentLocationButton.leadingAnchor.constraint(equalTo: leftQuickActionGuide.leadingAnchor, constant: 16),
			currentLocationButton.centerYAnchor.constraint(equalTo: leftQuickActionGuide.centerYAnchor),
			currentLocationButton.trailingAnchor.constraint(lessThanOrEqualTo: leftQuickActionGuide.trailingAnchor, constant: -8),
			currentLocationButton.heightAnchor.constraint(equalToConstant: 42),

			chooseOnMapButton.topAnchor.constraint(equalTo: routeSetupExpandedView.topAnchor),
			chooseOnMapButton.centerXAnchor.constraint(equalTo: rightQuickActionGuide.centerXAnchor),
			chooseOnMapButton.leadingAnchor.constraint(greaterThanOrEqualTo: rightQuickActionGuide.leadingAnchor, constant: 8),
			chooseOnMapButton.trailingAnchor.constraint(lessThanOrEqualTo: rightQuickActionGuide.trailingAnchor, constant: -16),
			chooseOnMapButton.heightAnchor.constraint(equalToConstant: 42),

			suggestionTableView.topAnchor.constraint(equalTo: currentLocationButton.bottomAnchor, constant: 2),
			suggestionTableView.leadingAnchor.constraint(equalTo: routeSetupExpandedView.leadingAnchor),
			suggestionTableView.trailingAnchor.constraint(equalTo: routeSetupExpandedView.trailingAnchor),
			suggestionTableView.bottomAnchor.constraint(equalTo: routeSetupExpandedView.bottomAnchor, constant: -15)
		])

		NSLayoutConstraint.activate([
			routeOriginIconView.widthAnchor.constraint(equalToConstant: 22),
			routeOriginIconView.heightAnchor.constraint(equalToConstant: 22),
			routeOriginIconView.topAnchor.constraint(equalTo: routeSetupHeaderView.topAnchor, constant: 15),
			routeOriginIconView.leadingAnchor.constraint(equalTo: routeSetupHeaderView.leadingAnchor, constant: 15),
			
			routeConnectorStackView.topAnchor.constraint(equalTo: routeOriginIconView.bottomAnchor, constant: 6),
			routeConnectorStackView.centerXAnchor.constraint(equalTo: routeOriginIconView.centerXAnchor),
			routeConnectorStackView.bottomAnchor.constraint(equalTo: routeDestinationIconView.topAnchor, constant: -6),

			routeDestinationIconView.widthAnchor.constraint(equalToConstant: 22),
			routeDestinationIconView.heightAnchor.constraint(equalToConstant: 22),
			routeDestinationIconView.topAnchor.constraint(equalTo: routeConnectorStackView.bottomAnchor),
			routeDestinationIconView.leadingAnchor.constraint(equalTo: routeSetupHeaderView.leadingAnchor, constant: 15),
			routeDestinationIconView.bottomAnchor.constraint(equalTo: routeSetupHeaderView.bottomAnchor, constant: -15),

			swapRouteButton.widthAnchor.constraint(equalToConstant: 36),
			swapRouteButton.heightAnchor.constraint(equalToConstant: 44),
			swapRouteButton.centerYAnchor.constraint(equalTo: routeSetupHeaderView.centerYAnchor),
			swapRouteButton.trailingAnchor.constraint(equalTo: routeSetupHeaderView.trailingAnchor, constant: -10),

			originTextField.topAnchor.constraint(equalTo: routeSetupHeaderView.topAnchor, constant: 8),
			originTextField.leadingAnchor.constraint(equalTo: routeOriginIconView.trailingAnchor, constant: 10),
			originTextField.trailingAnchor.constraint(equalTo: swapRouteButton.leadingAnchor, constant: -12),
			originTextField.heightAnchor.constraint(equalToConstant: 36),

			routeSetupDividerView.heightAnchor.constraint(equalToConstant: 1),
			routeSetupDividerView.centerYAnchor.constraint(equalTo: routeConnectorStackView.centerYAnchor),
			routeSetupDividerView.leadingAnchor.constraint(equalTo: originTextField.leadingAnchor),
			routeSetupDividerView.trailingAnchor.constraint(equalTo: swapRouteButton.leadingAnchor, constant: -12),

			destinationTextField.topAnchor.constraint(equalTo: routeSetupDividerView.bottomAnchor, constant: 8),
			destinationTextField.leadingAnchor.constraint(equalTo: originTextField.leadingAnchor),
			destinationTextField.trailingAnchor.constraint(equalTo: swapRouteButton.leadingAnchor, constant: -12),
			destinationTextField.heightAnchor.constraint(equalToConstant: 36),
		])

		zoomControlView.addSubview(zoomInBtn)
		zoomControlView.addSubview(zoomOutBtn)
		NSLayoutConstraint.activate([
			zoomInBtn.heightAnchor.constraint(equalToConstant: 50),
			zoomInBtn.topAnchor.constraint(equalTo: zoomControlView.topAnchor),
			zoomInBtn.leadingAnchor.constraint(equalTo: zoomControlView.leadingAnchor),
			zoomInBtn.trailingAnchor.constraint(equalTo: zoomControlView.trailingAnchor),
			
			zoomOutBtn.heightAnchor.constraint(equalToConstant: 50),
			zoomOutBtn.topAnchor.constraint(equalTo: zoomInBtn.bottomAnchor),
			zoomOutBtn.leadingAnchor.constraint(equalTo: zoomControlView.leadingAnchor),
			zoomOutBtn.trailingAnchor.constraint(equalTo: zoomControlView.trailingAnchor),
			zoomOutBtn.bottomAnchor.constraint(equalTo: zoomControlView.bottomAnchor)
		])
		
		// Force compass to stay at top-right corner regardless of padding
		mapView.compassView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.deactivate(mapView.compassView.constraints)

		NSLayoutConstraint.activate([
			mapView.compassView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
			mapView.compassView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
		])
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationController?.navigationBar.tintColor = .primary
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor:UIColor.primary,
			NSAttributedString.Key.font: UIFont.default(size: UIFont.normal)
		]
		navigationItem.standardAppearance = appearance
		view.backgroundColor = .screenBackground
		
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
		longPress.minimumPressDuration = 0.8 // seconds
		mapView.addGestureRecognizer(longPress)
		let locationManager = CLLocationManager()
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		if let location = locationManager.location {
			mapView.setCenter(location.coordinate, zoomLevel: 16, animated: false)
		}
		locationManager.stopUpdatingLocation()
		suggestionTableView.dataSource = self
		suggestionTableView.delegate = self
		
		originLoModel = LocationViewModel(isUserLocation: true, title: "Your location", coordinate: nil, distance: 0)
		originTextField.text = originLoModel?.title
		
		reloadRecentPlaces()
		
		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		locationBtn.addShadow(radius: 8)
		routeSetupContentView.addShadow(radius: 8)
		routeSetupContentView.layer.cornerRadius = 16
		zoomControlView.addShadow(radius: 8)
		routeSetupDividerView.cornerRadius()
		statusFadeMask.frame = bkStatusView.bounds
		statusFadeMask.colors = [
			UIColor.black.cgColor,
			UIColor.clear.cgColor
		]
		statusFadeMask.startPoint = CGPoint(x: 0.5, y: 0.0)
		statusFadeMask.endPoint = CGPoint(x: 0.5, y: 1.0)
		statusEffectView.layer.mask = statusFadeMask
	}

	private func reloadRecentPlaces() {
		let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
		let places = Const.dataManager.fetchData(Place.self, predicate: nil, sortDescriptors: [sortDescriptor])
		allPlaceModels = Array(places).map { PlaceListModel(place: $0) }
		applySearchResults()
	}

	
	private func applySearchResults() {
		let textField = editingRouteType == .origin ? originTextField : destinationTextField
		let keyword = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		if keyword.isEmpty {
			filteredPlaceModels = allPlaceModels
		} else {
			filteredPlaceModels = allPlaceModels.filter {
				$0.place.name?.lowercased().contains(keyword.lowercased()) == true
			}
		}
		suggestionTableView.reloadData()
	}

	private func updateExpandedLayout(isExpend: Bool) {
		let preferredHeight = expandedContentHeight()
		let maximumHeight = maxExpandedHeight()
		let resolvedHeight = min(preferredHeight, maximumHeight)
		routeSetupExpandedHeightAnchor?.constant = isExpend ? resolvedHeight : 0
		routeSetupExpandedView.isHidden = !isExpend
		suggestionTableView.isScrollEnabled = isExpend && preferredHeight > maximumHeight
		let animations = {
			self.view.layoutIfNeeded()
		}
		UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseInOut, animations: animations)
	}

	private func expandedContentHeight() -> CGFloat {
		let tableHeight = CGFloat(filteredPlaceModels.count) * suggestionTableView.rowHeight
		return 52 + tableHeight
	}

	private func maxExpandedHeight() -> CGFloat {
		view.layoutIfNeeded()
		let safeBottom = view.safeAreaLayoutGuide.layoutFrame.maxY
		let expandedTop = routeSetupExpandedView.convert(routeSetupExpandedView.bounds, to: view).minY
		let availableHeight = safeBottom - expandedTop - 8
		return max(0, availableHeight)
	}

	@objc private func handleKeyboardFrameChange(_ notification: Notification) {
		guard let userInfo = notification.userInfo,
			let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
			return
		}

		let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
		let animationCurveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UInt(UIView.AnimationCurve.easeInOut.rawValue)
		let animationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw << 16)
		let keyboardFrameInView = view.convert(keyboardFrameValue.cgRectValue, from: nil)
		let overlapHeight = max(0, view.bounds.maxY - keyboardFrameInView.minY - view.safeAreaInsets.bottom)
		routeSetupBottomAnchor?.constant = -(overlapHeight + 8)
		UIView.animate(withDuration: animationDuration, delay: 0, options: [animationOptions, .beginFromCurrentState]) {
			self.view.layoutIfNeeded()
		}
	}

	private func onUserPinnedAt(_ coordinate: CLLocationCoordinate2D) {
		destinationTextField.resignFirstResponder()
		previousCoordinates.removeAll()
		nextCoordinates.removeAll()
		
		if editingRouteType == .origin {
			if originLoModel == nil {
				originLoModel = LocationViewModel()
			}
			originLoModel?.title = "Dropped pin"
			var newOrigin = originLoModel
			newOrigin?.isUserLocation = false
			newOrigin?.coordinate = coordinate
			originLoModel = newOrigin
		}else {
			if destinationLoModel == nil {
				destinationLoModel = LocationViewModel()
			}
			destinationLoModel?.title = "Dropped pin"
			editingRouteType = .destination
			var newDestination = destinationLoModel
			newDestination?.coordinate = coordinate
			newDestination?.isUserLocation = false
			destinationLoModel = newDestination
		}
		
		// Setup marker
		addAnnotationAt(coordinate)
		
		// Find route
		onRouteLocationsUpdate()
		
		updateExpandedLayout(isExpend: false)
	}
	
	private func onUpdateOriginModel() {
		if originLoModel != nil && originLoModel!.isUserLocation {
			routeOriginIconView.image = UIImage(systemName: "circle.inset.filled")
			routeOriginIconView.tintColor = .primary
			originTextField.textColor = .primary
		}else {
			routeOriginIconView.image = UIImage(named: "ic_marker")
			routeOriginIconView.tintColor = .red
			originTextField.textColor = .black
		}
		originTextField.text = originLoModel?.title
	}
	
	private func onUpdateDestinationModel() {
		if destinationLoModel != nil {
			if destinationLoModel!.isUserLocation {
				routeDestinationIconView.image = UIImage(systemName: "circle.inset.filled")
				routeDestinationIconView.tintColor = .primary
				destinationTextField.textColor = .primary
				if destinationLoModel!.distance > 0 {
					destinationTextField.text = "\(destinationLoModel?.title ?? "") ( \(Utils.toDistance(meters: destinationLoModel!.distance)) )"
				}else {
					destinationTextField.text = destinationLoModel?.title ?? ""
				}
			}else {
				routeDestinationIconView.image = UIImage(named: "ic_marker")
				routeDestinationIconView.tintColor = .red
				destinationTextField.textColor = .black
				if destinationLoModel!.distance > 0 {
					destinationTextField.text = "\(destinationLoModel?.title ?? "") ( \(Utils.toDistance(meters: destinationLoModel!.distance)) )"
				}else {
					destinationTextField.text = destinationLoModel?.title ?? ""
				}
			}
		}else {
			routeDestinationIconView.image = UIImage(named: "ic_marker")
			routeDestinationIconView.tintColor = .red
			destinationTextField.textColor = .black
			destinationTextField.text = destinationLoModel?.title
		}
	}
	
	
	private func addAnnotationAt(_ coordinate: CLLocationCoordinate2D) {
		var pinnedID = "origin_pinned_annotation"
		if editingRouteType == .destination {
			pinnedID = "destination_pinned_annotation"
		}
		mapView.removeAnnotation(id: pinnedID)
		
		let annotation = PlaceAnnotation()
		annotation.coordinate = coordinate
		annotation.id = pinnedID
		mapView.addAnnotation(annotation)
	}
	
	
	private func onRouteLocationsUpdate() {
		guard let userCoor = mapView.userLocation?.coordinate else { return }
		let originCoor = originLoModel?.coordinate ?? userCoor
		let destinationCoor = destinationLoModel?.coordinate
		
		if destinationCoor == nil { return }
		
		SVProgressHUD.show(withStatus: "finding_route...".localized())
		DispatchQueue.global(qos: .default).async {
			let routeCoordinates = Const.routingProvider.coordinates(originCoor, destinationCoor!)
			
			let distance = Const.routingProvider.distance(routeCoordinates)
			DispatchQueue.main.async {
				if self.destinationLoModel != nil {
					self.destinationLoModel?.distance = distance
				}
				self.appendDestinationAddress(text: Utils.toDistance(meters: distance))
			}
			
			self.nextCoordinates = routeCoordinates
			self.drawRouteOnMap()
		}
	}

	private func appendDestinationAddress(text: String) {
		destinationTextField.attributedText = NSAttributedString().multiStyles(
			lineSpace: 0,
			resources: [
				[.default(size: 17): .black],
				[.defaultMedium(size: 17): .black],
			],
			texts: [
				destinationLoModel?.title ?? "",
				" ( \(text) )"
			]
			
		)
	}

	@objc private func onChooseOnMap() {
		originTextField.resignFirstResponder()
		destinationTextField.resignFirstResponder()
		updateExpandedLayout(isExpend: false)
		let message = editingRouteType == .origin ? "Long press on map to choose origin" : "Long press on map to choose destination"
		showToast(message: message)
		
	}

	@objc private func onUseCurrentLocation() {
		guard let coordinate = mapView.userLocation?.coordinate else {
			showToast(message: "Current location unavailable")
			return
		}
		mapView.setCenter(coordinate, zoomLevel: mapView.zoomLevel, animated: true)
		switch editingRouteType {
		case .origin:
			originTextField.resignFirstResponder()
		case .destination:
			destinationTextField.resignFirstResponder()
		}
		if editingRouteType == .origin {
			if originLoModel == nil {
				originLoModel = LocationViewModel()
			}
			var tmpOrigin = originLoModel
			tmpOrigin?.coordinate = coordinate
			tmpOrigin?.title = "Your location"
			tmpOrigin?.isUserLocation = true
			originLoModel = tmpOrigin
		}else {
			if destinationLoModel == nil {
				destinationLoModel = LocationViewModel()
			}
			var tmpDestination = destinationLoModel
			tmpDestination?.coordinate = coordinate
			tmpDestination?.title = "Your location"
			tmpDestination?.isUserLocation = true
			destinationLoModel = tmpDestination
		}
		previousCoordinates.removeAll()
		nextCoordinates.removeAll()
		onRouteLocationsUpdate()
		updateExpandedLayout(isExpend: false)
	}
	
	
	@objc private func onZoomIn() {
		mapView.setZoomLevel(mapView.zoomLevel + 0.5, animated: true)
	}
	
	@objc private func onZoomOut() {
		mapView.setZoomLevel(mapView.zoomLevel - 0.5, animated: true)
	}
	
	@objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
		if gesture.state == .began {
			// Get the point on screen
			let point = gesture.location(in: mapView)
				
			// Convert screen point to coordinate
			let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
			onUserPinnedAt(coordinate)
		}
	}

	@objc private func onSwapRouteDirection() {
		let tmpOrigin = originLoModel
		originLoModel = destinationLoModel
		destinationLoModel = tmpOrigin
		
		previousCoordinates.removeAll()
		nextCoordinates.removeAll()
		onRouteLocationsUpdate()
		
		updateExpandedLayout(isExpend: false)
	}

	private func clearActionState() {
		SVProgressHUD.dismiss()
		
		editingRouteType = .destination
		
		originTextField.resignFirstResponder()
		destinationTextField.resignFirstResponder()
		
		mapView.removeAnnotation(id: "origin_pinned_annotation")
		mapView.removeAnnotation(id: "destination_pinned_annotation")
		
		mapView.removePolyline(sourceID: "pinned_route_source_next", layerID: "pinne_route_layer_next")
		mapView.removePolyline(sourceID: "pinned_route_source_previous", layerID: "pinne_route_layer_previous")
		
		previousCoordinates.removeAll()
		nextCoordinates.removeAll()
		filteredPlaceModels.removeAll()
		
		originTextField.text = nil
		destinationTextField.text = nil
		
		updateExpandedLayout(isExpend: false)
	}
	
	private func drawRouteOnMap() {
		DispatchQueue.main.async {
			if self.nextCoordinates.count > 2 {
				self.mapView.addPolyline(
					coordinates: self.nextCoordinates,
					sourceID: "pinned_route_source_next",
					layerID: "pinne_route_layer_next",
					color: .blue,
					width: self.locationState == .indirect ? 10 : 6
				)
			}else {
				self.mapView.removePolyline(
					sourceID: "pinned_route_source_next",
					layerID: "pinne_route_layer_next"
				)
			}
			
			if self.previousCoordinates.count > 2 {
				self.mapView.addPolyline(
					coordinates: self.previousCoordinates,
					sourceID: "pinned_route_source_previous",
					layerID: "pinne_route_layer_previous",
					color: .lightGray,
					width: self.locationState == .indirect ? 10 : 6
				)
			}else {
				self.mapView.removePolyline(
					sourceID: "pinned_route_source_previous",
					layerID: "pinne_route_layer_previous"
				)
			}
			SVProgressHUD.dismiss()
		}
		
	}
	
	private func moveToCurrentLocation() {
		if isChangingMapPitch { return }
		if let coordinate = mapView.userLocation?.coordinate {
			let camera = mapView.camera
			if locationState == .indirect && camera.pitch == 0 {
				camera.pitch = 45
				isChangingMapPitch = true
			}else {
				if camera.pitch != 0 {
					camera.pitch = 0
					camera.heading = 0
					isChangingMapPitch = true
				}
			}
			camera.centerCoordinate = coordinate
			mapView.fly(to: camera, withDuration: 1) {
				if self.locationState == .indirect {
					self.mapView.userTrackingMode = .followWithHeading
				}else {
					self.mapView.userTrackingMode = .follow
				}
				self.isChangingMapPitch = false
			}
		}
	}
	
	@objc private func onClickLocationBtn() {
		if isChangingMapPitch { return }
		locationState = (locationState == .notFocus || locationState == .indirect) ? .focusing : .indirect
		moveToCurrentLocation()
	}
	
	private func updateLocationButton() {
		if isChangingMapPitch { return }
		UIApplication.shared.isIdleTimerDisabled = false
		switch locationState {
			case .notFocus:
				locationBtn.setImage(UIImage(systemName: "location"), for: .normal)
				mapView.setContentInset(.zero, animated: true) {}
			case .focusing:
				locationBtn.setImage(UIImage(systemName: "location.fill"), for: .normal)
				mapView.setContentInset(.zero, animated: true) {}
			case .indirect:
				UIApplication.shared.isIdleTimerDisabled = true
				let topPadding = self.view.frame.height - (self.view.frame.height * 0.4)
				let padding = UIEdgeInsets(top: topPadding, left: 0, bottom: 0, right: 0)
				mapView.setContentInset(padding, animated: true) {}
				locationBtn.setImage(UIImage(systemName: "location.north.line.fill"), for: .normal)
		}
		drawRouteOnMap()
	}
	
	private func updateRoute(userLocation: CLLocation) {
		let index = findNearestLocationIndex(userLocation)
		if index < 0 {
//			findRouteTo(pinnedCoordinate!)
			return
		}
		if previousCoordinates.count > 0 {
			previousCoordinates.removeLast()
		}
		previousCoordinates.append(contentsOf: Array(nextCoordinates[0...index]))
		if index == nextCoordinates.count - 1 {
			nextCoordinates.removeAll()
		}else {
			nextCoordinates.removeSubrange(0..<index)
		}
		drawRouteOnMap()
	}
	
	private func findNearestLocationIndex(_ location: CLLocation) -> Int {
		var nearestIndex: Int = 0
		var previousDistance: Double = location.distance(from: CLLocation(latitude: nextCoordinates[0].latitude, longitude: nextCoordinates[0].longitude))
		for i in 1..<nextCoordinates.count {
			let distance = location.distance(from: CLLocation(latitude: nextCoordinates[i].latitude, longitude: nextCoordinates[i].longitude))
			if distance < previousDistance {
				previousDistance = distance
				nearestIndex = i
			}else {
				break
			}
		}
		return previousDistance < 200 ? nearestIndex : -1
	}
}

extension MapsViewController: MLNMapViewDelegate {

	func mapView(_ mapView: MLNMapView, viewFor annotation: any MLNAnnotation) -> MLNAnnotationView? {
		// Skip user location annotation
		if annotation is MLNUserLocation {
			return nil
		}
		let image = UIImage(named: "places")!.withRenderingMode(.automatic).withTintColor(.red)
		let annotationV = PlaceAnnotationView(image: image, size: CGSize(width: 40, height: 40), bottom: 20)
		annotationV.isUserInteractionEnabled = true
		return annotationV
	}
	
	func mapView(_ mapView: MLNMapView, didUpdate userLocation: MLNUserLocation?) {
		guard let location = userLocation?.location else { return }
		if currentLocation == nil { return }
		let previousLocation = currentLocation
		currentLocation = location
		if nextCoordinates.isEmpty {
			return
		}
		let distance = previousLocation!.distance(from: location)
		
		if distance > 10 && destinationLoModel != nil {
			currentLocation = location
			updateRoute(userLocation: location)
		}
	}
	
	func mapView(_ mapView: MLNMapView, regionWillChangeWith reason: MLNCameraChangeReason, animated: Bool) {
		if reason.contains(.gesturePan) {
			if locationState != .indirect {
				locationState = .notFocus
			}
		}
	}
}

extension MapsViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		filteredPlaceModels.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeue(RoutePlaceSuggestionCell.self, for: indexPath)
		cell.configure(with: filteredPlaceModels[indexPath.row])
		return cell
	}
}

extension MapsViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let place = filteredPlaceModels[indexPath.row].place
		let coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
		mapView.setCenter(coordinate, zoomLevel: mapView.zoomLevel, animated: true)
		
		if editingRouteType == .origin {
			var newOrigin = originLoModel != nil ? originLoModel : LocationViewModel()
			newOrigin?.coordinate = coordinate
			newOrigin?.title = place.name ?? ""
			newOrigin?.isUserLocation = false
			originLoModel = newOrigin
			originTextField.resignFirstResponder()
		}else {
			var newDestination = destinationLoModel != nil ? destinationLoModel : LocationViewModel()
			newDestination?.coordinate = coordinate
			newDestination?.title = place.name ?? ""
			newDestination?.isUserLocation = false
			destinationLoModel = newDestination
			destinationTextField.resignFirstResponder()
		}
		
		// Setup marker
		addAnnotationAt(coordinate)
		
		// Find route
		onRouteLocationsUpdate()
		
		updateExpandedLayout(isExpend: false)
	}
}


extension MapsViewController: UITextFieldDelegate {
	
	func textFieldDidChangeSelection(_ textField: UITextField) {
		guard textField === destinationTextField || textField === originTextField else { return }
		editingRouteType = textField === originTextField ? .origin : .destination
		applySearchResults()
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		if editingRouteType == .destination {
			onUpdateDestinationModel()
		}else {
			onUpdateOriginModel()
		}
		updateExpandedLayout(isExpend: false)
		return true
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		guard textField === destinationTextField || textField === originTextField else { return }
		if editingRouteType == .origin {
			onUpdateDestinationModel()
		}else {
			onUpdateOriginModel()
		}
		
	}
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		guard textField === destinationTextField || textField === originTextField else { return true }
		editingRouteType = textField === originTextField ? .origin : .destination
		if textField === originTextField {
			originTextField.text = nil
			editingRouteType = .origin
		}else {
			destinationTextField.text = nil
			editingRouteType = .destination
		}
		applySearchResults()
		updateExpandedLayout(isExpend: true)
		return true
	}
}

