//
//  MapExportTemplateViewController.swift
//  TourMe
//
//  Created by Savet on 4/6/26.
//

import UIKit
import MapLibre

class MapExportTemplateViewController: UIViewController {
	
	private lazy var mapView: ToureMeMapView = {
		let mapV = ToureMeMapView(style: "map-style-road")
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
	
	override func loadView() {
		super.loadView()
		
		view.addSubview(mapView)
		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: view.topAnchor),
			mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let locationManager = CLLocationManager()
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		if let location = locationManager.location {
			mapView.setCenter(location.coordinate, zoomLevel: 16, animated: false)
		}
		locationManager.stopUpdatingLocation()
	}
}

extension MapExportTemplateViewController: MLNMapViewDelegate {

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
	
	func mapView(_ mapView: MLNMapView, regionWillChangeWith reason: MLNCameraChangeReason, animated: Bool) {
		if reason.contains(.gesturePan) {
//			if locationState != .indirect {
//				locationState = .notFocus
//			}
		}
	}
}
