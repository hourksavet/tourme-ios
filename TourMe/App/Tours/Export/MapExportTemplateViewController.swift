//
//  MapExportTemplateViewController.swift
//  TourMe
//
//  Created by Savet on 4/6/26.
//

import UIKit
import MapLibre
import SVProgressHUD

class MapExportTemplateViewController: UIViewController {

	private let carOnRouteAnnotaion = "map_export_car_annotation"
	
	private var centerCoordinate: CLLocationCoordinate2D?
	private var directionCoordinate: CLLocationCoordinate2D?
	
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
	
	init(tour: Tour) {
		super.init(nibName: nil, bundle: nil)
		self.tour = tour
		self.visitPlaces = (tour.visitPlaces?.array as? [VisitPlace]) ?? tour.visitPlaces?.compactMap({ $0 as? VisitPlace }) ?? []
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
		title = "Paper Map"
		view.backgroundColor = .screenBackground
		account = Const.dataManager.fetchData(Account.self).first
		let styleButton = UIBarButtonItem(
			image: UIImage(systemName: "slider.horizontal.3"),
			style: .plain,
			target: self,
			action: #selector(openMapChecklist)
		)
		let exportButton = UIBarButtonItem(
			image: UIImage(systemName: "square.and.arrow.up"),
			style: .plain,
			target: self,
			action: #selector(exportMapPDF)
		)
		navigationItem.rightBarButtonItems = [exportButton, styleButton]
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

	@objc private func exportMapPDF() {
		focusMapForExport { [weak self] restoreLayout in
			self?.shareMapPDF(completion: restoreLayout)
		}
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
		DispatchQueue.global(qos: .default).async {
			var segments: [([CLLocationCoordinate2D], String, String)] = []
			for index in 1..<visibleCoordinates.count {
				let routeCoordinates = Const.routingProvider.coordinates(visibleCoordinates[index - 1], visibleCoordinates[index])
				if index == 1 {
					let centerIndex: Int = routeCoordinates.count / 2
					if centerIndex > 0 {
						self.centerCoordinate = routeCoordinates[centerIndex]
						if centerIndex + 1 < routeCoordinates.count {
							self.directionCoordinate = routeCoordinates[centerIndex + 1]
						}
					}
				}
				if !routeCoordinates.isEmpty {
					segments.append((routeCoordinates, "export_route_source_\(index)", "export_route_layer_\(index)"))
				}
			}
			DispatchQueue.main.async {
				if self.centerCoordinate != nil {
					let carAnnotation = PlaceAnnotation()
					carAnnotation.id = self.carOnRouteAnnotaion
					carAnnotation.coordinate = self.centerCoordinate!
					carAnnotation.title = "Car"
					self.mapView.addAnnotation(carAnnotation)
				}
				
				for segment in segments {
					self.mapView.addPolyline(coordinates: segment.0, sourceID: segment.1, layerID: segment.2, color: .red, width: 4)
				}
				self.renderedRouteIDs = segments.map { ($0.1, $0.2) }
				self.boundCoordinates(visibleCoordinates)
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
		if let annotations = mapView.annotations {
			mapView.removeAnnotations(annotations)
		}
		for routeID in renderedRouteIDs {
			mapView.removePolyline(sourceID: routeID.0, layerID: routeID.1)
		}
		renderedRouteIDs.removeAll()
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

	private func focusMapForExport(completion: @escaping (@escaping () -> Void) -> Void) {
		let coordinates = exportCoordinates()
		guard let firstCoordinate = coordinates.first else {
			completion({})
			return
		}
		let originalFrame = mapView.frame
		let originalCenter = mapView.center
		let originalAutoresizingMask = mapView.autoresizingMask
		let originalTranslatesAutoresizingMask = mapView.translatesAutoresizingMaskIntoConstraints
		let exportFrame = CGRect(origin: .zero, size: exportPageSize())
		NSLayoutConstraint.deactivate(mapViewConstraints)
		mapView.translatesAutoresizingMaskIntoConstraints = true
		mapView.autoresizingMask = []
		mapView.frame = exportFrame
		mapView.center = originalCenter
		mapView.layoutIfNeeded()
		var bounds = MLNCoordinateBounds(sw: firstCoordinate, ne: firstCoordinate)
		for coordinate in coordinates.dropFirst() {
			bounds.sw.latitude = min(bounds.sw.latitude, coordinate.latitude)
			bounds.sw.longitude = min(bounds.sw.longitude, coordinate.longitude)
			bounds.ne.latitude = max(bounds.ne.latitude, coordinate.latitude)
			bounds.ne.longitude = max(bounds.ne.longitude, coordinate.longitude)
		}
		let exportPadding = exportEdgeInsets(for: exportFrame.size)
		mapView.setVisibleCoordinateBounds(bounds, edgePadding: exportPadding, animated: false) { [weak self] in
			guard let self else { return }
			if self.mapView.zoomLevel > 16 {
				self.mapView.setZoomLevel(16, animated: false)
			}
			self.mapView.layoutIfNeeded()
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
				completion {
					self.mapView.frame = originalFrame
					self.mapView.center = originalCenter
					self.mapView.autoresizingMask = originalAutoresizingMask
					self.mapView.translatesAutoresizingMaskIntoConstraints = originalTranslatesAutoresizingMask
					NSLayoutConstraint.activate(self.mapViewConstraints)
					self.view.layoutIfNeeded()
				}
			}
		}
	}

	private func shareMapPDF(completion: @escaping () -> Void) {
		let pageBounds = CGRect(origin: .zero, size: exportPageSize())
		let contentRect = exportContentRect(in: pageBounds)
		let mapIDFrame = exportMapIDFrame(in: contentRect)
		let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
		let data = renderer.pdfData { context in
			context.beginPage()
			UIColor.white.setFill()
			context.cgContext.fill(pageBounds)
			mapIDView.isHidden = false
			mapView.drawHierarchy(in: contentRect, afterScreenUpdates: true)
			mapIDView.isHidden = true
			mapIDView.drawHierarchy(in: mapIDFrame, afterScreenUpdates: true)
		}
		let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(pdfFileName())
		do {
			try data.write(to: tempURL, options: .atomic)
			completion()
			let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
			activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.first
			present(activityViewController, animated: true)
		} catch {
			completion()
			showToast(message: "Export failed")
		}
	}

	private func pdfFileName() -> String {
		let rawName = (tour.name?.isEmpty == false ? tour.name! : "tour-map")
		let sanitizedName = rawName.replacingOccurrences(of: "/", with: "-")
		return "\(sanitizedName).pdf"
	}

	private func exportPageSize() -> CGSize {
		// Poster-style 3:2 landscape canvas matching the provided reference layout.
		return CGSize(width: 1800, height: 1200)
	}

	private func exportContentRect(in pageBounds: CGRect) -> CGRect {
		guard mapView.bounds.width > 0, mapView.bounds.height > 0 else {
			return pageBounds.insetBy(dx: 80, dy: 80)
		}

		let horizontalInset: CGFloat = 20
		let verticalInset: CGFloat = 20
		let availableRect = pageBounds.insetBy(dx: horizontalInset, dy: verticalInset)
		let widthScale = availableRect.width / mapView.bounds.width
		let heightScale = availableRect.height / mapView.bounds.height
		let scale = min(widthScale, heightScale)
		let targetSize = CGSize(width: mapView.bounds.width * scale, height: mapView.bounds.height * scale)
		let origin = CGPoint(
			x: pageBounds.midX - (targetSize.width / 2),
			y: pageBounds.midY - (targetSize.height / 2)
		)
		return CGRect(origin: origin, size: targetSize)
	}

	private func exportEdgeInsets(for size: CGSize) -> UIEdgeInsets {
		let horizontalInset = max(size.width * 0.06, 56)
		let verticalInset = max(size.height * 0.08, 72)
		return UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
	}

	private func exportMapIDFrame(in contentRect: CGRect) -> CGRect {
		mapIDView.setNeedsLayout()
		mapIDView.layoutIfNeeded()
		let fittedSize = mapIDView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		let sourceFrame = mapIDView.frame == .zero ? CGRect(origin: CGPoint(x: 16, y: mapView.bounds.height - fittedSize.height - 16), size: fittedSize) : mapIDView.frame
		guard mapView.bounds.width > 0, mapView.bounds.height > 0 else {
			return CGRect(origin: CGPoint(x: contentRect.minX + 20, y: contentRect.maxY - fittedSize.height - 20), size: fittedSize)
		}

		let scaleX = contentRect.width / mapView.bounds.width
		let scaleY = contentRect.height / mapView.bounds.height
		return CGRect(
			x: contentRect.minX + (sourceFrame.minX * scaleX),
			y: contentRect.minY + (sourceFrame.minY * scaleY),
			width: sourceFrame.width * scaleX,
			height: sourceFrame.height * scaleY
		)
	}

	private func carRotationAngle() -> CGFloat {
		guard let centerCoordinate, let directionCoordinate else { return 0 }
		let latitudeDelta = directionCoordinate.latitude - centerCoordinate.latitude
		let longitudeDelta = directionCoordinate.longitude - centerCoordinate.longitude
		guard latitudeDelta != 0 || longitudeDelta != 0 else { return 0 }
		return CGFloat(atan2(longitudeDelta, latitudeDelta))
	}
}

extension MapExportTemplateViewController: MLNMapViewDelegate {

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
			let annotationView = ExportPlaceImageAnnotationView(imageData: thumb, size: CGSize(width: 100, height: 100))
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
