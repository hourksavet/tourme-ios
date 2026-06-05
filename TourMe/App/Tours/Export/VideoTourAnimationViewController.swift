//
//  VideoTourAnimationViewController.swift
//  TourMe
//
//  Created by Savet on 5/6/26.
//

import UIKit
import ReplayKit
import MapLibre
import SVProgressHUD

class VideoTourAnimationViewController: UIViewController {

	private let carOnRouteAnnotaion = "map_export_car_annotation"
	
	private var routeCoordinates: [CLLocationCoordinate2D] = []
	private var animatedRouteCoordinates: [CLLocationCoordinate2D] = []
	private var routeDestinationCoordinates: [CLLocationCoordinate2D] = []
	private var routeDestinationIndices: [Int] = []
	private var animatedDestinationIndices: [Int] = []
	private var centerCoordinate: CLLocationCoordinate2D?
	private var directionCoordinate: CLLocationCoordinate2D?
	private var carAnnotation: PlaceAnnotation?
	private var carAnimationTimer: Timer?
	private var exportStopTimer: Timer?
	private var currentRouteIndex: Int = 0
	private var currentDestinationIndex: Int = 0
	private let followCameraZoomLevel: Double = 15
	private let followCameraPitch: CGFloat = 45
	private let carAnimationInterval: TimeInterval = 0.06
	private let maxPreviewDuration: TimeInterval = 30
	private let maxVideoExportDuration: TimeInterval = 30
	private var isRecordingExport = false
	private var isPreviewingAnimation = false
	private var wasNavigationBarHiddenBeforeRecording = false
	private var wasMapLogoHiddenBeforeRecording = false
	private var wasAttributionButtonHiddenBeforeRecording = false
	private var wasCompassHiddenBeforeRecording = false
	private var wasMapIDHiddenBeforeRecording = true
	
	private lazy var mapView: ToureMeMapView = {
		let mapV = ToureMeMapView(style: "map-style-road")
		mapV.showsUserLocation = false
		mapV.showsUserHeadingIndicator = false
		mapV.layoutMargins = .zero
		mapV.isRotateEnabled = false
		mapV.delegate = self
		mapV.automaticallyAdjustsContentInset = false
		mapV.translatesAutoresizingMaskIntoConstraints = false
		return mapV
	}()
	
	private lazy var mapIDView: MapIDView = {
		let view = MapIDView()
		view.layer.cornerRadius = 6
		view.isHidden = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private var tour: Tour!
	private var visitPlaces: [VisitPlace] = []
	private var renderedRouteIDs: [(String, String)] = []
	private var renderVersion: Int = 0
	private var account: Account?
	private var mapViewConstraints: [NSLayoutConstraint] = []
	private lazy var previewBarButtonItem: UIBarButtonItem = {
		let button = UIBarButtonItem(
			title: "Preview",
			style: .plain,
			target: self,
			action: #selector(onPreviewAnimation)
		)
		button.isEnabled = false
		return button
	}()
	private lazy var exportBarButtonItem: UIBarButtonItem = {
		let button = UIBarButtonItem(
			image: UIImage(systemName: "record.circle"),
			style: .plain,
			target: self,
			action: #selector(exportAnimationVideo)
		)
		button.isEnabled = false
		return button
	}()
	private lazy var styleBarButtonItem: UIBarButtonItem = {
		UIBarButtonItem(
			image: UIImage(systemName: "slider.horizontal.3"),
			style: .plain,
			target: self,
			action: #selector(openMapChecklist)
		)
	}()
	
	init(tour: Tour) {
		super.init(nibName: nil, bundle: nil)
		self.tour = tour
		self.visitPlaces = (tour.visitPlaces?.array as? [VisitPlace]) ?? tour.visitPlaces?.compactMap({ $0 as? VisitPlace }) ?? []
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var prefersStatusBarHidden: Bool {
		isRecordingExport || isPreviewingAnimation
	}
	
	override func loadView() {
		super.loadView()
		
		view.addSubview(mapView)
		mapViewConstraints = [
			mapView.topAnchor.constraint(equalTo: view.topAnchor),
			mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		]
		NSLayoutConstraint.activate(mapViewConstraints)
		
		mapView.addSubview(mapIDView)
		NSLayoutConstraint.activate([
			mapIDView.centerYAnchor.constraint(equalTo: mapView.logoView.centerYAnchor),
			mapIDView.leadingAnchor.constraint(equalTo: mapView.logoView.trailingAnchor, constant: 10)
		])
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .screenBackground
		account = Const.dataManager.fetchData(Account.self).first
		navigationItem.rightBarButtonItems = [exportBarButtonItem, styleBarButtonItem, previewBarButtonItem]
	}

	@objc private func openMapChecklist() {
		let checklistViewController = MapCustomCheckListViewController()
		checklistViewController.onApplyStyleJSON = { [weak self] styleJSON in
			guard let self else { return }
			self.mapView.applyStyleJSON(styleJSON, cacheKey: "map-export-preview")
		}
		let viewController = checklistViewController.toNavigationController()
		viewController.modalPresentationStyle = .overFullScreen
		present(viewController, animated: true)
	}

	@objc private func onPreviewAnimation() {
		startCarAnimationIfNeeded(hideControlsDuringPlayback: true)
	}

	@objc private func exportAnimationVideo() {
		guard routeCoordinates.count > 1 else {
			showToast(message: "No route to export")
			return
		}
		startScreenRecordingExport()
	}

	private func renderMap() {
		clearMapContent()
		let placeCoordinates = visitPlaces.compactMap { visitPlace -> CLLocationCoordinate2D? in
			guard let place = visitPlace.place else { return nil }
			return CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
		}
		var visibleCoordinates = placeCoordinates

		if let startCoordinate = startCoordinate() {
			let startAnnotation = PlaceAnnotation()
			startAnnotation.coordinate = startCoordinate
			startAnnotation.title = "Start"
			mapView.addAnnotation(startAnnotation)
			visibleCoordinates.insert(startCoordinate, at: 0)
		}

		for visitPlace in visitPlaces {
			guard let place = visitPlace.place else { continue }
			let annotation = PlaceAnnotation()
			annotation.id = place.id?.uuidString ?? UUID().uuidString
			annotation.coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
			annotation.title = place.name
			mapView.addAnnotation(annotation)
		}

		guard !visibleCoordinates.isEmpty else { return }
		guard visibleCoordinates.count > 1 else {
			boundCoordinates(visibleCoordinates)
			return
		}
		SVProgressHUD.show(withStatus: "finding_route...".localized())
		routeCoordinates = []
		routeDestinationCoordinates = []
		routeDestinationIndices = []
		DispatchQueue.global(qos: .default).async {
			var segments: [([CLLocationCoordinate2D], String, String)] = []
			var collectedRouteCoordinates: [CLLocationCoordinate2D] = []
			var destinationCoordinates: [CLLocationCoordinate2D] = []
			var destinationIndices: [Int] = []
			for index in 1..<visibleCoordinates.count {
				let routeCoordinates = Const.routingProvider.coordinates(visibleCoordinates[index - 1], visibleCoordinates[index])
				if collectedRouteCoordinates.isEmpty {
					collectedRouteCoordinates.append(contentsOf: routeCoordinates)
				} else if let firstRouteCoordinate = routeCoordinates.first,
					let lastCollectedCoordinate = collectedRouteCoordinates.last,
					firstRouteCoordinate.latitude == lastCollectedCoordinate.latitude,
					firstRouteCoordinate.longitude == lastCollectedCoordinate.longitude {
					collectedRouteCoordinates.append(contentsOf: routeCoordinates.dropFirst())
				} else {
					collectedRouteCoordinates.append(contentsOf: routeCoordinates)
				}
				if !routeCoordinates.isEmpty {
					destinationCoordinates.append(visibleCoordinates[index])
					destinationIndices.append(max(collectedRouteCoordinates.count - 1, 0))
					segments.append((routeCoordinates, "export_route_source_\(index)", "export_route_layer_\(index)"))
				}
			}
			DispatchQueue.main.async {
				self.routeCoordinates = collectedRouteCoordinates
				self.routeDestinationCoordinates = destinationCoordinates
				self.routeDestinationIndices = destinationIndices
				for segment in segments {
					self.mapView.addPolyline(coordinates: segment.0, sourceID: segment.1, layerID: segment.2, color: .red, width: 4)
				}
				self.renderedRouteIDs = segments.map { ($0.1, $0.2) }
				self.boundCoordinates(visibleCoordinates)
				let hasRoute = self.routeCoordinates.count > 1
				self.previewBarButtonItem.isEnabled = hasRoute
				self.exportBarButtonItem.isEnabled = hasRoute
				SVProgressHUD.dismiss()
			}
		}
		boundCoordinates(visibleCoordinates)
	}

	private func startCoordinate() -> CLLocationCoordinate2D? {
		guard tour.startLat != 0 || tour.startLng != 0 else { return nil }
		return CLLocationCoordinate2D(latitude: tour.startLat, longitude: tour.startLng)
	}

	private func clearMapContent() {
		stopCarAnimation()
		previewBarButtonItem.isEnabled = false
		exportBarButtonItem.isEnabled = false
		if let annotations = mapView.annotations {
			mapView.removeAnnotations(annotations)
		}
		for routeID in renderedRouteIDs {
			mapView.removePolyline(sourceID: routeID.0, layerID: routeID.1)
		}
		renderedRouteIDs.removeAll()
		animatedRouteCoordinates.removeAll()
		animatedDestinationIndices.removeAll()
		carAnnotation = nil
	}

	private func startCarAnimationIfNeeded(hideControlsDuringPlayback: Bool = false) {
		stopCarAnimation(shouldFinishRecording: false)
		if hideControlsDuringPlayback {
			isPreviewingAnimation = true
			setRecordingControlsHidden(true)
		}
		animatedRouteCoordinates = cappedAnimationRouteCoordinates(
			from: routeCoordinates,
			maxDuration: maxPreviewDuration,
			frameInterval: carAnimationInterval
		)
		animatedDestinationIndices = mappedAnimatedDestinationIndices(
			for: routeDestinationIndices,
			sourceCount: routeCoordinates.count,
			animatedCount: animatedRouteCoordinates.count
		)
		guard animatedRouteCoordinates.count > 1 else {
			if hideControlsDuringPlayback {
				isPreviewingAnimation = false
				setRecordingControlsHidden(false)
			}
			return
		}

		currentRouteIndex = 0
		currentDestinationIndex = 0
		centerCoordinate = animatedRouteCoordinates[0]
		directionCoordinate = animatedRouteCoordinates[1]

		let annotation = PlaceAnnotation()
		annotation.id = carOnRouteAnnotaion
		annotation.coordinate = animatedRouteCoordinates[0]
		annotation.title = "Car"
		carAnnotation = annotation
		mapView.addAnnotation(annotation)
		refreshCarAnnotationView()

		carAnimationTimer = Timer.scheduledTimer(withTimeInterval: carAnimationInterval, repeats: true) { [weak self] _ in
			self?.moveCarToNextCoordinate()
		}
	}

	private func moveCarToNextCoordinate() {
		guard animatedRouteCoordinates.count > 1 else {
			stopCarAnimation()
			return
		}

		let nextIndex = currentRouteIndex + 1
		guard nextIndex < animatedRouteCoordinates.count else {
			stopCarAnimation()
			return
		}

		centerCoordinate = animatedRouteCoordinates[currentRouteIndex]
		directionCoordinate = animatedRouteCoordinates[nextIndex]
		carAnnotation?.coordinate = animatedRouteCoordinates[nextIndex]
		currentRouteIndex = nextIndex
		updateCurrentDestinationIndex()
		refreshCarAnnotationView()
	}

	private func refreshCarAnnotationView() {
		guard let carAnnotation else { return }
		if let annotationView = mapView.view(for: carAnnotation) as? ExportProfilePinAnnotationView {
			annotationView.updateCarRotation(carRotationAngle())
		} else {
			mapView.removeAnnotation(carAnnotation)
			mapView.addAnnotation(carAnnotation)
		}
	}

	private func stopCarAnimation(shouldFinishRecording: Bool = true) {
		carAnimationTimer?.invalidate()
		carAnimationTimer = nil
		exportStopTimer?.invalidate()
		exportStopTimer = nil
		currentRouteIndex = 0
		currentDestinationIndex = 0
		if isPreviewingAnimation {
			isPreviewingAnimation = false
			setRecordingControlsHidden(false)
		}
		if shouldFinishRecording, isRecordingExport {
			finishScreenRecordingExport()
		}
	}

	private func startScreenRecordingExport() {
		let recorder = RPScreenRecorder.shared()
		guard recorder.isAvailable else {
			showToast(message: "Video export failed")
			return
		}

		stopCarAnimation(shouldFinishRecording: false)
		setRecordingControlsHidden(true)
		previewBarButtonItem.isEnabled = false
		exportBarButtonItem.isEnabled = false
		isRecordingExport = true

		recorder.startRecording { [weak self] error in
			DispatchQueue.main.async {
				guard let self else { return }
				if error != nil {
					self.isRecordingExport = false
					self.setRecordingControlsHidden(false)
					SVProgressHUD.dismiss()
					self.setAnimationButtonsEnabled()
					self.showToast(message: "Video export failed")
					return
				}
				self.startCarAnimationIfNeeded()
				self.exportStopTimer = Timer.scheduledTimer(withTimeInterval: self.maxVideoExportDuration, repeats: false) { [weak self] _ in
					self?.finishScreenRecordingExport()
				}
			}
		}
	}

	private func finishScreenRecordingExport() {
		guard isRecordingExport else { return }
		isRecordingExport = false
		exportStopTimer?.invalidate()
		exportStopTimer = nil

		RPScreenRecorder.shared().stopRecording { [weak self] previewController, error in
			DispatchQueue.main.async {
				guard let self else { return }
				self.setRecordingControlsHidden(false)
				SVProgressHUD.dismiss()
				self.setAnimationButtonsEnabled()
				if let previewController {
					previewController.previewControllerDelegate = self
					self.present(previewController, animated: true)
				} else {
					self.showToast(message: "Video export failed")
				}
			}
		}
	}

	private func setRecordingControlsHidden(_ isHidden: Bool) {
		setNeedsStatusBarAppearanceUpdate()

		if isHidden {
			wasNavigationBarHiddenBeforeRecording = navigationController?.isNavigationBarHidden ?? false
			wasMapLogoHiddenBeforeRecording = mapView.logoView.isHidden
			wasAttributionButtonHiddenBeforeRecording = mapView.attributionButton.isHidden
			wasCompassHiddenBeforeRecording = mapView.compassView.isHidden
			wasMapIDHiddenBeforeRecording = mapIDView.isHidden
			navigationController?.setNavigationBarHidden(true, animated: false)
			mapView.logoView.isHidden = true
			mapView.attributionButton.isHidden = true
			mapView.compassView.isHidden = true
			mapIDView.isHidden = true
			return
		}

		navigationController?.setNavigationBarHidden(wasNavigationBarHiddenBeforeRecording, animated: false)
		mapView.logoView.isHidden = wasMapLogoHiddenBeforeRecording
		mapView.attributionButton.isHidden = wasAttributionButtonHiddenBeforeRecording
		mapView.compassView.isHidden = wasCompassHiddenBeforeRecording
		mapIDView.isHidden = wasMapIDHiddenBeforeRecording
	}

	private func setAnimationButtonsEnabled() {
		let hasRoute = routeCoordinates.count > 1
		previewBarButtonItem.isEnabled = hasRoute
		exportBarButtonItem.isEnabled = hasRoute
	}

	private func updateCurrentDestinationIndex() {
		guard !animatedDestinationIndices.isEmpty else { return }
		while currentDestinationIndex < animatedDestinationIndices.count - 1,
			currentRouteIndex >= animatedDestinationIndices[currentDestinationIndex] {
			currentDestinationIndex += 1
		}
	}

	private func cappedAnimationRouteCoordinates(from coordinates: [CLLocationCoordinate2D], maxDuration: TimeInterval, frameInterval: TimeInterval) -> [CLLocationCoordinate2D] {
		let smoothedCoordinates = smoothRouteCoordinates(from: coordinates)
		let frameLimit = max(2, Int(maxDuration / frameInterval))
		guard smoothedCoordinates.count > frameLimit else { return smoothedCoordinates }

		var cappedCoordinates: [CLLocationCoordinate2D] = []
		for frame in 0..<frameLimit {
			let progress = Double(frame) / Double(frameLimit - 1)
			let sourceIndex = Int(round(progress * Double(smoothedCoordinates.count - 1)))
			cappedCoordinates.append(smoothedCoordinates[sourceIndex])
		}
		return cappedCoordinates
	}

	private func mappedAnimatedDestinationIndices(for sourceIndices: [Int], sourceCount: Int, animatedCount: Int) -> [Int] {
		guard sourceCount > 1, animatedCount > 1 else { return [] }
		return sourceIndices.map { sourceIndex in
			let progress = Double(sourceIndex) / Double(sourceCount - 1)
			return min(animatedCount - 1, Int(round(progress * Double(animatedCount - 1))))
		}
	}

	private func smoothRouteCoordinates(from coordinates: [CLLocationCoordinate2D], stepsPerSegment: Int = 10) -> [CLLocationCoordinate2D] {
		guard coordinates.count > 1 else { return coordinates }
		var smoothedCoordinates: [CLLocationCoordinate2D] = [coordinates[0]]

		for index in 1..<coordinates.count {
			let start = coordinates[index - 1]
			let end = coordinates[index]
			for step in 1...stepsPerSegment {
				let progress = CLLocationDegrees(step) / CLLocationDegrees(stepsPerSegment)
				let latitude = start.latitude + ((end.latitude - start.latitude) * progress)
				let longitude = start.longitude + ((end.longitude - start.longitude) * progress)
				smoothedCoordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
			}
		}

		return smoothedCoordinates
	}

	private func boundCameraForAnimationStart() {
		guard let centerCoordinate else { return }
		if let destinationCoordinate = currentDestinationCoordinate() {
			var bounds = MLNCoordinateBounds(sw: centerCoordinate, ne: centerCoordinate)
			bounds.sw.latitude = min(bounds.sw.latitude, destinationCoordinate.latitude)
			bounds.sw.longitude = min(bounds.sw.longitude, destinationCoordinate.longitude)
			bounds.ne.latitude = max(bounds.ne.latitude, destinationCoordinate.latitude)
			bounds.ne.longitude = max(bounds.ne.longitude, destinationCoordinate.longitude)
			mapView.setVisibleCoordinateBounds(bounds, edgePadding: UIEdgeInsets(top: 140, left: 90, bottom: 220, right: 90), animated: false) { [weak self] in
				guard let self else { return }
				var camera = self.mapView.camera
				camera.pitch = self.followCameraPitch
				camera.heading = 0
				self.mapView.setCamera(camera, animated: false)
			}
			return
		}
		mapView.setCenter(centerCoordinate, zoomLevel: min(max(mapView.zoomLevel, 13.5), followCameraZoomLevel), animated: false)
		var camera = mapView.camera
		camera.centerCoordinate = centerCoordinate
		camera.pitch = followCameraPitch
		camera.heading = 0
		mapView.setCamera(camera, animated: false)
	}

	private func currentDestinationCoordinate() -> CLLocationCoordinate2D? {
		guard !routeDestinationCoordinates.isEmpty else { return nil }
		let safeIndex = min(currentDestinationIndex, routeDestinationCoordinates.count - 1)
		return routeDestinationCoordinates[safeIndex]
	}

	private func boundCoordinates(_ coordinates: [CLLocationCoordinate2D]) {
		guard let firstCoordinate = coordinates.first else { return }
		var bounds = MLNCoordinateBounds(sw: firstCoordinate, ne: firstCoordinate)
		for coordinate in coordinates.dropFirst() {
			bounds.sw.latitude = min(bounds.sw.latitude, coordinate.latitude)
			bounds.sw.longitude = min(bounds.sw.longitude, coordinate.longitude)
			bounds.ne.latitude = max(bounds.ne.latitude, coordinate.latitude)
			bounds.ne.longitude = max(bounds.ne.longitude, coordinate.longitude)
		}
		mapView.setVisibleCoordinateBounds(bounds, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: false) { }
	}

	private func exportCoordinates() -> [CLLocationCoordinate2D] {
		var coordinates = visitPlaces.compactMap { visitPlace -> CLLocationCoordinate2D? in
			guard let place = visitPlace.place else { return nil }
			return CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
		}
		if let startCoordinate = startCoordinate() {
			coordinates.insert(startCoordinate, at: 0)
		}
		return coordinates
	}

	private func exportDensityLevel() -> Int {
		let count = visitPlaces.count
		if count >= 12 || coordinateSpreadScore() < 1.2 {
			return 2
		}
		if count >= 7 || coordinateSpreadScore() < 2.4 {
			return 1
		}
		return 0
	}

	private func coordinateSpreadScore() -> CLLocationDegrees {
		let coordinates = exportCoordinates()
		guard let firstCoordinate = coordinates.first else { return .greatestFiniteMagnitude }
		var minLatitude = firstCoordinate.latitude
		var maxLatitude = firstCoordinate.latitude
		var minLongitude = firstCoordinate.longitude
		var maxLongitude = firstCoordinate.longitude
		for coordinate in coordinates.dropFirst() {
			minLatitude = min(minLatitude, coordinate.latitude)
			maxLatitude = max(maxLatitude, coordinate.latitude)
			minLongitude = min(minLongitude, coordinate.longitude)
			maxLongitude = max(maxLongitude, coordinate.longitude)
		}
		return max(maxLatitude - minLatitude, maxLongitude - minLongitude)
	}

	private func exportPlaceAnnotationSize() -> CGSize {
		switch exportDensityLevel() {
		case 2:
			return CGSize(width: 64, height: 64)
		case 1:
			return CGSize(width: 80, height: 80)
		default:
			return CGSize(width: 100, height: 100)
		}
	}

	private func exportPlaceAnnotationOffset(for placeID: String?) -> CGPoint {
		guard let placeID,
			let index = visitPlaces.firstIndex(where: { $0.place?.id?.uuidString == placeID })
		else {
			return .zero
		}

		let radius: CGFloat
		switch exportDensityLevel() {
		case 2:
			radius = 28
		case 1:
			radius = 18
		default:
			radius = 0
		}
		guard radius > 0 else { return .zero }

		let pattern: [CGPoint] = [
			CGPoint(x: 0, y: -radius),
			CGPoint(x: radius, y: -radius * 0.45),
			CGPoint(x: radius, y: radius * 0.45),
			CGPoint(x: 0, y: radius),
			CGPoint(x: -radius, y: radius * 0.45),
			CGPoint(x: -radius, y: -radius * 0.45)
		]
		return pattern[index % pattern.count]
	}

	private func carRotationAngle() -> CGFloat {
		guard let centerCoordinate, let directionCoordinate else { return 0 }
		let latitudeDelta = directionCoordinate.latitude - centerCoordinate.latitude
		let longitudeDelta = directionCoordinate.longitude - centerCoordinate.longitude
		guard latitudeDelta != 0 || longitudeDelta != 0 else { return 0 }
		return CGFloat(atan2(longitudeDelta, latitudeDelta))
	}

}

extension VideoTourAnimationViewController: RPPreviewViewControllerDelegate {

	func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
		previewController.dismiss(animated: true)
	}
}

extension VideoTourAnimationViewController: MLNMapViewDelegate {

	func mapView(_ mapView: MLNMapView, viewFor annotation: any MLNAnnotation) -> MLNAnnotationView? {
		// Skip user location annotation
		if annotation is MLNUserLocation {
			return nil
		}

		guard let placeAnnotation = annotation as? PlaceAnnotation else {
			return nil
		}
		
		if placeAnnotation.id == carOnRouteAnnotaion {
			let image = startMarkerImage()
			let annotationView = ExportProfilePinAnnotationView(image: image, size: CGSize(width: 76, height: 100), carRotation: carRotationAngle())
			annotationView.isUserInteractionEnabled = true
			return annotationView
		}

		if let place = visitPlaces.compactMap(\ .place).first(where: { $0.id?.uuidString == placeAnnotation.id }),
		   let thumb = place.thumb {
			let annotationView = ExportPlaceImageAnnotationView(imageData: thumb, size: exportPlaceAnnotationSize())
			let annotationOffset = exportPlaceAnnotationOffset(for: placeAnnotation.id)
			annotationView.centerOffset = CGVector(dx: annotationOffset.x, dy: annotationOffset.y)
			annotationView.isUserInteractionEnabled = true
			return annotationView
		}

		let image = UIImage(named: "places")!.withRenderingMode(.automatic).withTintColor(.red)
		let annotationView = PlaceAnnotationView(image: image, size: CGSize(width: 40, height: 40), bottom: 20)
		annotationView.isUserInteractionEnabled = true
		return annotationView
	}

	private func startMarkerImage() -> UIImage {
		if let profileData = account?.profile, let profileImage = UIImage(data: profileData) {
			return profileImage
		}
		if let account {
			return account.gender == "F" ? (UIImage(named: "ic-default-woman") ?? UIImage(named: "profile-user") ?? UIImage()) : (UIImage(named: "ic-default-man") ?? UIImage(named: "profile-user") ?? UIImage())
		}
		return UIImage(named: "profile-user") ?? UIImage(systemName: "person.circle.fill") ?? UIImage()
	}

	func mapViewDidFinishLoadingMap(_ mapView: MLNMapView) {
		renderMap()
	}
}
