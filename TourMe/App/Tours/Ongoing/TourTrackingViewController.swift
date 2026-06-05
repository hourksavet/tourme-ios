//
//  TourTrackingViewController.swift
//  TourMe
//
//  Created by Savet on 31/7/25.
//

import UIKit
import MapLibre

enum LocationMode {
	case focusing
	case indirect
	case notFocus
}

class TourTrackingViewController: UIViewController {

	private struct PlaceMenuAction {
		let title: String
		let image: UIImage?
		let isDestructive: Bool
		let handler: () -> Void
	}

	private var tour: Tour!
	private var visitPlaces: [VisitPlace] = []
	private var isAddedAnnotation: Bool = false
	private var isShowingActionsView: Bool = false
	private var vehicleAnnotationV: PlaceAnnotationView!
	private var trackingIndexPath: IndexPath?
	
	private lazy var mapView: ToureMeMapView = {
		let mapV = ToureMeMapView()
		mapV.minimumZoomLevel = 6
		mapV.maximumZoomLevel = 18
		mapV.isRotateEnabled = false
		mapV.compassViewPosition = .topRight
		mapV.compassView.isUserInteractionEnabled = false
		mapV.automaticallyAdjustsContentInset = false
		mapV.translatesAutoresizingMaskIntoConstraints = false
		return mapV
	}()
	
	private lazy var tourInfoButton: RoundButton = {
		let button = RoundButton(radius: 8, activeColor: .white, inactiveColor: .white)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.tintColor = .primary
		button.alpha = 0.9
		button.addTarget(self, action: #selector(showTourDetails), for: .touchUpInside)
		return button
	}()
	
	private lazy var mapZoomsView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.alpha = 0.9
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var mapActionsView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.alpha = 0.9
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var bkStatusView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var statusEffectView: UIVisualEffectView = {
		let effect = UIBlurEffect(style: .systemMaterialLight)
		let view = UIVisualEffectView(effect: effect)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let statusFadeMask = CAGradientLayer()
	
	private lazy var memberLinkButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.tintColor = .primary
		button.setImage(UIImage(named: "member_link"), for: .normal)
		button.alpha = 0.9
		button.addTarget(self, action: #selector(showMapStyles), for: .touchUpInside)
		return button
	}()
	
	private lazy var locationBtn: UIButton = {
		let button = UIButton(type: .system)
		button.tintColor = .primary
		button.setImage(UIImage(systemName: "location.fill"), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(onClickedLocationButton), for: .touchUpInside)
		return button
	}()
	
	private lazy var zoomInButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(named: "icon+"), for: .normal)
		button.tintColor = .primary
		button.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
		return button
	}()
	
	private lazy var zoomOutButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(named: "icon-"), for: .normal)
		button.tintColor = .primary
		button.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
		return button
	}()
	
	private lazy var endTourButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("end_tour".localized(), for: .normal)
		button.titleLabel?.font = .defaultMedium(size: 17)
		button.isHidden = false
		button.backgroundColor = .primary
		button.tintColor = .white
		button.addTarget(self, action: #selector(endTour), for: .touchUpInside)
		return button
	}()
	
	private lazy var placesCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 8
		layout.itemSize = CGSize(width: view.bounds.width - 30, height: 100)
		layout.sectionInset = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(PlaceTrackingViewCell.self, forCellWithReuseIdentifier: "cell")
		collectionView.backgroundColor = .clear
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()
	
	private var annotationIDs: [String] = []
	private var routeIDs: [String] = []
	
	private var vehicleAnnotation: PlaceAnnotation!

	private var locationManager: CLLocationManager!
	private var currentLocation: CLLocation?
	private var currentHeading: Double!
	
	private var calculatedLocation: CLLocation?
	private var previousCoordinates: [CLLocationCoordinate2D] = []
	private var nextCoordinates: [CLLocationCoordinate2D] = []
	
	private var isChangingMapPitch: Bool = false
	
	private var locationMode: LocationMode = .focusing
	
	init(tour: Tour) {
		super.init(nibName: nil, bundle: nil)
		self.tour = tour
		if let visitPls = tour.visitPlaces?.compactMap({$0 as? VisitPlace}) {
			visitPlaces = visitPls
			checkTourCompleted()
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		view.addSubview(mapView)
		view.addSubview(bkStatusView)
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
			statusEffectView.bottomAnchor.constraint(equalTo: bkStatusView.bottomAnchor)
		])
		
		view.addSubview(mapZoomsView)
		view.addSubview(tourInfoButton)
		view.addSubview(mapActionsView)
		view.addSubview(endTourButton)
		view.addSubview(placesCollectionView)
		NSLayoutConstraint.activate([
			mapZoomsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
			mapZoomsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			
			tourInfoButton.widthAnchor.constraint(equalToConstant: 44),
			tourInfoButton.heightAnchor.constraint(equalToConstant: 44),
			tourInfoButton.bottomAnchor.constraint(equalTo: mapActionsView.topAnchor, constant: -8),
			tourInfoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			
			mapActionsView.widthAnchor.constraint(equalToConstant: 44),
			mapActionsView.heightAnchor.constraint(equalToConstant: 89),
			mapActionsView.bottomAnchor.constraint(equalTo: placesCollectionView.topAnchor, constant: -10),
			mapActionsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			
			endTourButton.heightAnchor.constraint(equalToConstant: 44),
			endTourButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
			endTourButton.trailingAnchor.constraint(equalTo: mapActionsView.leadingAnchor, constant: -15),
			endTourButton.bottomAnchor.constraint(equalTo: placesCollectionView.topAnchor, constant: -10),
			
			placesCollectionView.heightAnchor.constraint(equalToConstant: 120),
			placesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			placesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			placesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
		
		mapActionsView.addSubview(memberLinkButton)
		mapActionsView.addSubview(locationBtn)
		NSLayoutConstraint.activate([
			memberLinkButton.topAnchor.constraint(equalTo: mapActionsView.topAnchor),
			memberLinkButton.leadingAnchor.constraint(equalTo: mapActionsView.leadingAnchor),
			memberLinkButton.trailingAnchor.constraint(equalTo: mapActionsView.trailingAnchor),
			memberLinkButton.bottomAnchor.constraint(equalTo: mapActionsView.centerYAnchor),
			locationBtn.topAnchor.constraint(equalTo: mapActionsView.centerYAnchor),
			locationBtn.leadingAnchor.constraint(equalTo: mapActionsView.leadingAnchor),
			locationBtn.trailingAnchor.constraint(equalTo: mapActionsView.trailingAnchor),
			locationBtn.bottomAnchor.constraint(equalTo: mapActionsView.bottomAnchor),
		])
		
		let spV = UIView()
		spV.backgroundColor = UIColor(hexString: "E5E5E5")
		spV.alpha = 0.5
		spV.translatesAutoresizingMaskIntoConstraints = false
		spV.layer.cornerRadius = 1
		mapActionsView.addSubview(spV)
		NSLayoutConstraint.activate([
			spV.heightAnchor.constraint(equalToConstant: 2),
			spV.centerYAnchor.constraint(equalTo: mapActionsView.centerYAnchor),
			spV.leadingAnchor.constraint(equalTo: mapActionsView.leadingAnchor, constant: 8),
			spV.trailingAnchor.constraint(equalTo: mapActionsView.trailingAnchor, constant: -8),
		])
		
		mapZoomsView.addSubview(zoomInButton)
		mapZoomsView.addSubview(zoomOutButton)
		NSLayoutConstraint.activate([
			zoomInButton.widthAnchor.constraint(equalToConstant: 44),
			zoomInButton.heightAnchor.constraint(equalToConstant: 40),
			zoomInButton.topAnchor.constraint(equalTo: mapZoomsView.topAnchor),
			zoomInButton.leadingAnchor.constraint(equalTo: mapZoomsView.leadingAnchor),
			zoomInButton.trailingAnchor.constraint(equalTo: mapZoomsView.trailingAnchor),
			
			zoomOutButton.widthAnchor.constraint(equalToConstant: 44),
			zoomOutButton.heightAnchor.constraint(equalToConstant: 40),
			zoomOutButton.topAnchor.constraint(equalTo: zoomInButton.bottomAnchor),
			zoomOutButton.bottomAnchor.constraint(equalTo: mapZoomsView.bottomAnchor)
		])
		
		let spV2 = UIView()
		spV2.backgroundColor = UIColor(hexString: "E5E5E5")
		spV2.alpha = 0.5
		spV2.translatesAutoresizingMaskIntoConstraints = false
		spV2.layer.cornerRadius = 1
		mapZoomsView.addSubview(spV2)
		NSLayoutConstraint.activate([
			spV2.heightAnchor.constraint(equalToConstant: 2),
			spV2.centerYAnchor.constraint(equalTo: mapZoomsView.centerYAnchor),
			spV2.leadingAnchor.constraint(equalTo: mapZoomsView.leadingAnchor, constant: 8),
			spV2.trailingAnchor.constraint(equalTo: mapZoomsView.trailingAnchor, constant: -8),
		])
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		mapView.delegate = self
		// Location manager
		locationManager = CLLocationManager()
		locationManager.distanceFilter = 1
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		
		view.backgroundColor = .screenBackground
		
		let icon = tour.vehicle == "CAR" ? UIImage(named: "ic_car")! : UIImage(named: "ic_motorcycle")!
		tourInfoButton.setImage(icon.withRenderingMode(.alwaysTemplate), for: .normal)
		vehicleAnnotation = PlaceAnnotation()
		vehicleAnnotation.id = "Vehicle"
		mapView.addAnnotation(vehicleAnnotation)
		if let coor = locationManager.location?.coordinate {
			vehicleAnnotation.coordinate = coor
			mapView.setCenter(coor, zoomLevel: 17, animated: false)
		}else {
			let coor = CLLocationCoordinate2D(latitude: 13.412447, longitude: 103.865495)
			vehicleAnnotation.coordinate = coor
			mapView.setCenter(coor, zoomLevel: 17, animated: false)
		}
		
		placesCollectionView.delegate = self
		placesCollectionView.dataSource = self
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		UIApplication.shared.isIdleTimerDisabled = true
		let bottomPadding = view.frame.height - placesCollectionView.frame.origin.y - view.safeAreaInsets.bottom - 10
		let padding = UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding, right: 0)
		setMapPadding(padding)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		UIApplication.shared.isIdleTimerDisabled = false
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		mapActionsView.addShadow(radius: 8)
		mapZoomsView.addShadow(radius: 8)
		endTourButton.addShadow(radius: 8)

		statusFadeMask.frame = bkStatusView.bounds
		statusFadeMask.colors = [
			UIColor.black.cgColor,
			UIColor.clear.cgColor
		]
		statusFadeMask.startPoint = CGPoint(x: 0.5, y: 0.0)
		statusFadeMask.endPoint = CGPoint(x: 0.5, y: 1.0)
		statusEffectView.layer.mask = statusFadeMask
	}
	
	private func addPlacesAnnotationOnMap() {
		annotationIDs.removeAll()
		for visitPl in visitPlaces.reversed() {
			guard let place = visitPl.place else { continue }
			let placeAnnotation = PlaceAnnotation()
			placeAnnotation.id = place.id?.uuidString ?? ""
			annotationIDs.append(placeAnnotation.id)
			placeAnnotation.coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
			placeAnnotation.title = place.name
			mapView.addAnnotation(placeAnnotation)
		}
		if tour.inDeparture {
			if let index = visitPlaces.firstIndex(where: { $0.status == .onging || $0.status == .arrived }),
			   let place = visitPlaces[index].place {
				trackingIndexPath = IndexPath(row: index, section: 0)
				routeTo(place: place, index: index)
				placesCollectionView.scrollToItem(at: trackingIndexPath!, at: .centeredHorizontally, animated: true)
			}
		}else {
			routingBetweenPlaces()
		}
	}

	private func routeOriginCoordinate() -> CLLocationCoordinate2D? {
		if let coordinate = currentLocation?.coordinate {
			return coordinate
		}
		if let coordinate = locationManager?.location?.coordinate {
			return coordinate
		}
		if tour.startLat != 0 || tour.startLng != 0 {
			return CLLocationCoordinate2D(latitude: tour.startLat, longitude: tour.startLng)
		}
		if vehicleAnnotation != nil {
			return vehicleAnnotation.coordinate
		}
		return nil
	}
	
	private func routingBetweenPlaces() {
		guard let originCoordinate = routeOriginCoordinate() else { return }
		let places = visitPlaces.compactMap(\ .place)
		guard !places.isEmpty else { return }
		var routeCoors: [CLLocationCoordinate2D] = [originCoordinate]
		routeCoors.append(contentsOf: places.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng) })
		DispatchQueue.global(qos: .default).async {
			var resolvedRouteIDs: [String] = []
			var segmentResults: [(id: String, coordinates: [CLLocationCoordinate2D])] = []
			var metricUpdates: [(index: Int, distance: Double, duration: Double)] = []
			var fromCoor: CLLocationCoordinate2D = routeCoors.first!
			for i in 1..<routeCoors.count {
				let toCoor = routeCoors[i]
				let routeCoordinates = Const.routingProvider.coordinates(fromCoor, toCoor)
				if self.visitPlaces[i - 1].distance == 0 {
					let distance = Const.routingProvider.distance(routeCoordinates)
					let duration = Const.routingProvider.travelDuration(fromCoor, toCoor)
					metricUpdates.append((index: i - 1, distance: Double(distance), duration: Double(duration)))
				}
				let id = self.visitPlaces[i - 1].place?.id?.uuidString ?? ""
				resolvedRouteIDs.append(id)
				segmentResults.append((id: id, coordinates: routeCoordinates))
				fromCoor = toCoor
			}
			DispatchQueue.main.async {
				self.routeIDs = resolvedRouteIDs
				for update in metricUpdates {
					self.visitPlaces[update.index].distance = update.distance
					self.visitPlaces[update.index].duration = update.duration
				}
				for segment in segmentResults {
					self.drawRouteOnMap(segment.coordinates, uuid: segment.id)
				}
			}
		}
	}
	
	private func drawRouteOnMap(_ coordinates: [CLLocationCoordinate2D], uuid: String) {
		DispatchQueue.main.async {
			self.mapView.addPolyline(
				coordinates: coordinates,
				sourceID: "line_source_\(uuid)",
				layerID: "line_layer_\(uuid)",
				color: .random,
				width: 6
			)
		}
	}
	
	private func routeTo(place: Place, index: Int) {
		guard let currentCoor = routeOriginCoordinate() else { return }
		let placeCoor = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
		DispatchQueue.global(qos: .default).async {
			let routeCoordinates = Const.routingProvider.coordinates(currentCoor, placeCoor)
			let distance = Const.routingProvider.distance(routeCoordinates)
			DispatchQueue.main.async {
				self.nextCoordinates = routeCoordinates
				self.visitPlaces[index].distance = Double(distance)
				let indexPath = IndexPath(item: index, section: 0)
				self.placesCollectionView.reloadItems(at: [indexPath])
				let id = place.id?.uuidString ?? ""
				self.routeIDs.append(id)
				self.drawGoingRoute()
			}
		}
	}
	
	private func drawGoingRoute() {
		DispatchQueue.main.async {
			if self.nextCoordinates.count > 2 {
				guard let trackingIndexPath = self.trackingIndexPath else { return }
				let distance = Const.routingProvider.distance(self.nextCoordinates)
				self.mapView.addPolyline(
					coordinates: self.nextCoordinates,
					sourceID: "going_route_source_next",
					layerID: "going_route_layer_next",
					color: .blue,
					width: 10
				)
				self.visitPlaces[trackingIndexPath.row].distance = Double(distance)
				self.placesCollectionView.reloadItems(at: [trackingIndexPath])
			}
			
			if self.previousCoordinates.count > 2 {
				self.mapView.addPolyline(
					coordinates: self.previousCoordinates,
					sourceID: "going_route_source_previous",
					layerID: "going_route_layer_previous",
					color: .lightGray,
					width: 10
				)
			}
		}
	}
	
	@objc private func showTourDetails() {
		let progressTourVC = ProgressTourDetailsViewController(tour, isPresented: true)
		progressTourVC.onTourUpdated = { tour in
			self.tourProgressUpdated(tour: tour)
		}
		let nvc = progressTourVC.toNavigationController()
		nvc.modalPresentationStyle = .overFullScreen
		present(nvc, animated: true)
	}
	
	@objc private func tourProgressUpdated(tour: Tour) {
		self.tour = tour
		if let visitPls = tour.visitPlaces?.compactMap({$0 as? VisitPlace}) {
			self.visitPlaces = visitPls
		}
		self.placesCollectionView.reloadData()
		let icon = tour.vehicle == "CAR" ? UIImage(named: "ic_car")! : UIImage(named: "ic_motorcycle")!
		self.tourInfoButton.setImage(icon.withRenderingMode(.alwaysTemplate), for: .normal)
		self.cleanMap()
		self.addPlacesAnnotationOnMap()
		self.checkTourCompleted()
	}
	
	private func cleanMap() {
		for id in annotationIDs {
			mapView.removeAnnotation(id: id)
		}
		for id in routeIDs {
			mapView.removePolyline(sourceID: "line_source_\(id)", layerID: "line_layer_\(id)")
		}
		annotationIDs.removeAll()
		routeIDs.removeAll()
	}
	
	private func clearRoutes() {
		for id in routeIDs {
			mapView.removePolyline(sourceID: "line_source_\(id)", layerID: "line_layer_\(id)")
		}
		routeIDs.removeAll()
	}
	
	private func clearGoingRoute() {
		mapView.removePolyline(sourceID: "going_route_source_next", layerID: "going_route_layer_next")
		mapView.removePolyline(sourceID: "going_route_source_previous", layerID: "going_route_layer_previous")
	}
	
	@objc private func showMapStyles() {
		let memberLinkVC = TourMemberLinkedViewController()
		memberLinkVC.modalPresentationStyle = .fullScreen
		present(memberLinkVC, animated: true, completion: nil)
	}
	
	@objc private func onClickedLocationButton() {
		if let coordinate = currentLocation != nil ? currentLocation!.coordinate : mapView.userLocation?.coordinate {
			currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			switch self.locationMode {
				case .focusing:
					self.locationMode = .indirect
					self.locationManager.startUpdatingHeading()
					self.locationBtn.setImage(UIImage(systemName: "location.north.line.fill"), for: .normal)
					vehicleAnnotationV.transform = CGAffineTransform(rotationAngle: 0)
					let topPadding = self.view.frame.height - (self.view.frame.height * 0.5)
					let bottomPadding = view.frame.height - placesCollectionView.frame.origin.y - view.safeAreaInsets.bottom - 10
					let padding = UIEdgeInsets(top: topPadding, left: 0, bottom: bottomPadding, right: 0)
					setMapPadding(padding)
					UIApplication.shared.isIdleTimerDisabled = true
					if trackingIndexPath != nil {
						placesCollectionView.scrollToItem(at: trackingIndexPath!, at: .centeredHorizontally, animated: true)
					}
					
				case .indirect, .notFocus:
					self.locationMode = .focusing
					self.locationManager.stopUpdatingHeading()
					self.locationBtn.setImage(UIImage(systemName: "location.fill"), for: .normal)
					let bottomPadding = view.frame.height - placesCollectionView.frame.origin.y - view.safeAreaInsets.bottom - 10
					let padding = UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding, right: 0)
					setMapPadding(padding)
					UIApplication.shared.isIdleTimerDisabled = false
			}
		}
	}
	
	private func setMapPadding(_ padding: UIEdgeInsets) {
		mapView.setContentInset(padding, animated: true) {
			self.moveCameraToCurrentLocation()
		}
	}
	
	private func moveCameraToCurrentLocation() {
		if currentLocation == nil { return }
		if isChangingMapPitch { return }
		let camera = mapView.camera
		
		camera.centerCoordinate = currentLocation!.coordinate
		if locationMode == .indirect {
			camera.heading = currentHeading ?? 0
			camera.pitch = 45
			isChangingMapPitch = true
		}else {
			if camera.pitch != 0 {
				camera.pitch = 0
				camera.heading = 0
				isChangingMapPitch = true
			}
		}
		mapView.fly(to: camera, withDuration: 1) {
			self.isChangingMapPitch = false
		}
	}
	
	@objc private func zoomIn() {
		let currentZoom = mapView.zoomLevel
		mapView.setZoomLevel(min(18, currentZoom + 1), animated: true)
	}
	
	@objc private func zoomOut() {
		let currentZoom = mapView.zoomLevel
		mapView.setZoomLevel(max(currentZoom - 1, 6), animated: true)
	}
	
	@objc private func endTour() {
		tour.endDate = Date()
		do {
			try Const.dataManager.context.save()
		}catch {}
		NotificationCenter.default.post(name: Utils.observerName(.endedTour), object: nil)
	}
	
	private func checkTourCompleted() {
		var isEnded: Bool = true
		for place in visitPlaces {
			if place.ended_date == nil {
				isEnded = false
				break
			}
		}
		endTourButton.isHidden = !isEnded
	}

	private func menuActions(at indexPath: IndexPath) -> [PlaceMenuAction] {
		let visitPl = visitPlaces[indexPath.row]
		if visitPl.status == .waiting {
			if tour.inDeparture {
				let delete = PlaceMenuAction(
					title: "Remove",
					image: UIImage(systemName: "trash"),
					isDestructive: true
				) {
					
				}
				return [delete]
			}

			let departure = PlaceMenuAction(
				title: "Departure to",
				image: UIImage(systemName: "airplane.departure"),
				isDestructive: false
			) {
				self.tour.inDeparture = true
				self.visitPlaces[indexPath.row].departure_date = Date()
				self.visitPlaces[indexPath.row].status_code = VisitPlaceStatus.onging.rawValue
				do {
					try Const.dataManager.context.save()
				} catch {}
				self.placesCollectionView.reloadItems(at: [indexPath])
				self.clearRoutes()
				self.trackingIndexPath = indexPath
				self.routeTo(place: self.visitPlaces[indexPath.row].place!, index: indexPath.row)
			}
			let delete = PlaceMenuAction(
				title: "Remove",
				image: UIImage(systemName: "trash"),
				isDestructive: true
			) {
				
			}
			return [departure, delete]
		}

		if visitPl.status == .onging {
			let arrived = PlaceMenuAction(
				title: "Arrived",
				image: UIImage(systemName: "airplane.arrival"),
				isDestructive: false
			) {
				self.visitPlaces[indexPath.row].arrived_date = Date()
				self.visitPlaces[indexPath.row].status_code = VisitPlaceStatus.arrived.rawValue
				do {
					try Const.dataManager.context.save()
				}catch {}
				self.placesCollectionView.reloadItems(at: [indexPath])
			}
				
			let cancel = PlaceMenuAction(
				title: "Return",
				image: UIImage(systemName: "return"),
				isDestructive: true
			) {
				self.tour.inDeparture = false
				self.visitPlaces[indexPath.row].departure_date = nil
				self.visitPlaces[indexPath.row].status_code = VisitPlaceStatus.waiting.rawValue
				do {
					try Const.dataManager.context.save()
				}catch {}
				self.placesCollectionView.reloadItems(at: [indexPath])
				self.routingBetweenPlaces()
				self.clearGoingRoute()
			}
			return [arrived, cancel]
		}

		if visitPl.status == .arrived {
			let endVisit = PlaceMenuAction(
				title: "End Visiting",
				image: UIImage(systemName: "tray.and.arrow.down.fill"),
				isDestructive: false
			) {
				self.visitPlaces[indexPath.row].ended_date = Date()
				self.tour.inDeparture = false
				self.visitPlaces[indexPath.row].status_code = VisitPlaceStatus.visited.rawValue
				self.visitPlaces[indexPath.row].place?.visitCount += 1
				do {
					try Const.dataManager.context.save()
				}catch {}
				self.placesCollectionView.reloadItems(at: [indexPath])
				self.checkTourCompleted()
			}
				
			let share = PlaceMenuAction(
				title: "Return",
				image: UIImage(systemName: "return"),
				isDestructive: true
			) {
				self.visitPlaces[indexPath.row].arrived_date = nil
				self.visitPlaces[indexPath.row].status_code = VisitPlaceStatus.onging.rawValue
				self.trackingIndexPath = indexPath
				self.routeTo(place: self.visitPlaces[indexPath.row].place!, index: indexPath.row)
				do {
					try Const.dataManager.context.save()
				}catch {}
				self.placesCollectionView.reloadItems(at: [indexPath])
			}
			return [endVisit, share]
		}

		let done = PlaceMenuAction(
			title: "Done",
			image: UIImage(systemName: "checkmark"),
			isDestructive: false
		) {
			
		}
		return [done]
	}
	
	private func setupMenu(at indexPath: IndexPath) -> UIMenu? {
		let visitPl = visitPlaces[indexPath.row]
		let title = visitPl.status == .visited ? "You have visted this place." : visitPl.place?.name
		let actions = menuActions(at: indexPath).map { item in
			UIAction(
				title: item.title,
				image: item.image,
				attributes: item.isDestructive ? .destructive : []
			) { _ in
				item.handler()
			}
		}
		return UIMenu(title: title ?? "", children: actions)
	}

	private func presentMenuActions(at indexPath: IndexPath) {
		let visitPl = visitPlaces[indexPath.row]
		let actionSheet = UIAlertController(title: visitPl.place?.name, message: visitPl.status == .visited ? "You have visted this place." : nil, preferredStyle: .actionSheet)

		for action in menuActions(at: indexPath) {
			let style: UIAlertAction.Style = action.isDestructive ? .destructive : .default
			actionSheet.addAction(UIAlertAction(title: action.title, style: style) { _ in
				action.handler()
			})
		}

		actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		if let cell = placesCollectionView.cellForItem(at: indexPath) {
			actionSheet.popoverPresentationController?.sourceView = cell
			actionSheet.popoverPresentationController?.sourceRect = cell.bounds
		}

		present(actionSheet, animated: true)
	}
	
	private func updateRoute(userLocation: CLLocation) {
		let index = findNearestLocationIndex(userLocation)
		if index < 0 {
			if trackingIndexPath != nil {
				let place = visitPlaces[trackingIndexPath!.row].place!
				routeTo(place: place, index: trackingIndexPath!.row)
			}
			return
		}
		if previousCoordinates.count > 0 {
			previousCoordinates.removeLast()
		}
		if nextCoordinates.count == 0 { return}
		previousCoordinates.append(contentsOf: Array(nextCoordinates[0...index]))
		if index == nextCoordinates.count - 1 {
			nextCoordinates.removeAll()
		}else {
			nextCoordinates.removeSubrange(0..<index)
		}
		drawGoingRoute()
	}
	
	private func findNearestLocationIndex(_ location: CLLocation) -> Int {
		if nextCoordinates.count == 0 { return 0 }
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

extension TourTrackingViewController: MLNMapViewDelegate {
	
	func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
		if !isAddedAnnotation {
			isAddedAnnotation = true
			addPlacesAnnotationOnMap()
		}
	}
	
	func mapView(_ mapView: MLNMapView, viewFor annotation: any MLNAnnotation) -> MLNAnnotationView? {
		// Skip user location annotation
		if annotation is MLNUserLocation {
			return nil
		}

		if let an = annotation as? PlaceAnnotation {
			if an.id == "Vehicle" && vehicleAnnotationV == nil {
				let image = UIImage(named: "car-top-view")!
				vehicleAnnotationV = PlaceAnnotationView(image: image, size: CGSize(width: 60, height: 60))
				return vehicleAnnotationV
			}else {
				if let visitPl = visitPlaces.first(where: { $0.place!.id?.uuidString ?? "" == an.id }) {
					if let thumb = visitPl.place!.thumb {
						let annotationV = PlaceThumAnnotationView(image: thumb, size: CGSize(width: 60, height: 60))
						return annotationV
					}
				}
			}
		}
		return nil
	}
	
}

extension TourTrackingViewController: UISearchTextFieldDelegate {
	
	func textFieldDidChangeSelection(_ textField: UITextField) {
		
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

extension TourTrackingViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		if calculatedLocation == nil {
			calculatedLocation = location
		}else {
			let distance = calculatedLocation!.distance(from: location)
			if distance > 10 {
				calculatedLocation = location
				updateRoute(userLocation: location)
			}
		}
		currentLocation = location
		if vehicleAnnotation != nil {
			UIView.animate(withDuration: 1.0) {
				self.vehicleAnnotation.coordinate = location.coordinate
				switch self.locationMode {
					case.indirect, .focusing:
						self.moveCameraToCurrentLocation()
					default:
						break
						
				}
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		currentHeading = newHeading.magneticHeading
		let camera = self.mapView.camera
		camera.heading = self.currentHeading
		self.mapView.setCamera(camera, animated: true)
	}
}

extension TourTrackingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return visitPlaces.count
	}
		
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PlaceTrackingViewCell
		cell.layer.cornerRadius = 8
		cell.selectedBackgroundView = UIView()
		cell.configure(with: visitPlaces[indexPath.row], index: indexPath.row)
		cell.addShadow(radius: 8)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		return true
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		presentMenuActions(at: indexPath)
	}
	
	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			return self.setupMenu(at: indexPath)
		}
	}
}
