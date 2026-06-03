//
//  MapsViewCell.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit
import CoreLocation
import MapLibre
import SVProgressHUD

class MapsViewCell: UITableViewCell, CellID {
	
	private lazy var playSpeedLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
		label.font = .defaultMedium(size: UIFont.normal)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var playSpeedButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("play".localized(), for: .normal)
		button.setTitleColor(.primary, for: .normal)
		button.titleLabel?.font = .defaultMedium(size: UIFont.medium)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var animateButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("animate".localized(), for: .normal)
		button.setTitleColor(.primary, for: .normal)
		button.titleLabel?.font = .defaultMedium(size: UIFont.medium)
		button.addTarget(self, action: #selector(clickedAnimate), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var mapView: ToureMeMapView = {
		let mapV = ToureMeMapView()
		mapV.showsUserLocation = true
		mapV.userTrackingMode = .follow
		mapV.isRotateEnabled = false
		mapV.translatesAutoresizingMaskIntoConstraints = false
		return mapV
	}()
	
	private lazy var locationBtn: UIButton = {
		let button = UIButton(type: .system)
		button.tintColor = .primary
		button.backgroundColor = .white
		button.alpha = 0.9
		button.setImage(UIImage(systemName: "location.fill"), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(moveToCurrentLocation), for: .touchUpInside)
		return button
	}()
	
	private lazy var iconDistanceImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.image = UIImage(named: "ic_route_distance")
		imgV.isHidden = true
		imgV.translatesAutoresizingMaskIntoConstraints = false
		return imgV
	}()
	
	private lazy var distanceLbl: UILabel = {
		let lbl = UILabel()
		lbl.translatesAutoresizingMaskIntoConstraints = false
		return lbl
	}()
	
	private var isRunDefaultBound: Bool = false
	private var markerCoordinates: [CLLocationCoordinate2D] = []
	private var places: [Place] = []
	private var tourDistance: Int = 0
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(animateButton)
		contentView.addSubview(mapView)
		contentView.addSubview(locationBtn)
		contentView.addSubview(iconDistanceImgV)
		contentView.addSubview(distanceLbl)
		
		NSLayoutConstraint.activate([
			animateButton.topAnchor.constraint(equalTo: contentView.topAnchor),
			animateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
			
			mapView.topAnchor.constraint(equalTo: animateButton.bottomAnchor, constant: 5),
			mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			
			locationBtn.widthAnchor.constraint(equalToConstant: 40),
			locationBtn.heightAnchor.constraint(equalToConstant: 40),
			locationBtn.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
			locationBtn.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -10),
			
			iconDistanceImgV.widthAnchor.constraint(equalToConstant: 20),
			iconDistanceImgV.heightAnchor.constraint(equalToConstant: 20),
			iconDistanceImgV.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 15),
			iconDistanceImgV.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 10),
			iconDistanceImgV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			
			distanceLbl.centerYAnchor.constraint(equalTo: iconDistanceImgV.centerYAnchor),
			distanceLbl.leadingAnchor.constraint(equalTo: iconDistanceImgV.trailingAnchor, constant: 10)
		])
		locationBtn.addShadow(radius: 20)
		mapView.layer.cornerRadius = 15
		backgroundColor = .clear
		mapView.delegate = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc private func clickedAnimate() {
		var totalDistance: Int = 0
		if mapView.userLocation == nil || tourDistance != 0 { return }
		SVProgressHUD.show()
		markerCoordinates.removeAll()
		if let userCoordinates = mapView.userLocation?.coordinate {
			markerCoordinates.append(userCoordinates)
		}else {
			return
		}
		for place in places {
			markerCoordinates.append(CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng))
		}
		DispatchQueue.global(qos: .default).async {
			var fromCoor: CLLocationCoordinate2D = self.markerCoordinates.first!
			var toCoor: CLLocationCoordinate2D!
			for i in 1..<self.markerCoordinates.count {
				toCoor = self.markerCoordinates[i]
				let routeCoordinates = Const.routingProvider.coordinates(fromCoor, toCoor)
				totalDistance += Const.routingProvider.distance(routeCoordinates)
				self.drawRouteOnMap(routeCoordinates, uuid: "\(i)")
				fromCoor = toCoor!
			}
			DispatchQueue.main.async {
				self.iconDistanceImgV.isHidden = false
				self.distanceLbl.text = "\(totalDistance / 1000) \("km".localized())"
				self.boundCoordinates(self.markerCoordinates)
				SVProgressHUD.dismiss()
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
	
	@objc private func moveToCurrentLocation() {
		if let coordinate = mapView.userLocation?.coordinate {
			let camera = MLNMapCamera(lookingAtCenter: coordinate, altitude: mapView.camera.altitude, pitch: 0, heading: 0)
			mapView.setCamera(camera, animated: true)
		}
	}
	
	private func boundCoordinates(_ coordinates: [CLLocationCoordinate2D]) {
		// Create a bounds object
		var bounds = MLNCoordinateBounds(sw: coordinates[0], ne: coordinates[0])

		// Expand bounds with all marker coordinates
		for i in 1..<coordinates.count {
			bounds.sw.latitude  = min(bounds.sw.latitude, coordinates[i].latitude)
			bounds.sw.longitude = min(bounds.sw.longitude, coordinates[i].longitude)
			bounds.ne.latitude  = max(bounds.ne.latitude, coordinates[i].latitude)
			bounds.ne.longitude = max(bounds.ne.longitude, coordinates[i].longitude)
		}

		// Apply padding (so markers aren’t at the very edge of screen)
		let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)

		// Move camera to fit all markers
		mapView.setVisibleCoordinateBounds(bounds, edgePadding: insets, animated: true) {}
	}
	
	func configur(places: [Place]) {
		self.places = places
		var routeCoors: [CLLocationCoordinate2D] = []
		for place in places {
			// Create a point annotation
			let annotation = PlaceAnnotation()
			annotation.id = place.id?.uuidString ?? ""
			annotation.coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
			annotation.title = place.name
			mapView.addAnnotation(annotation)
			routeCoors.append(annotation.coordinate)
		}
		markerCoordinates = routeCoors
	}
}

extension MapsViewCell: MLNMapViewDelegate {
	
	func mapView(_ mapView: MLNMapView, viewFor annotation: any MLNAnnotation) -> MLNAnnotationView? {
		// Skip user location annotation
		if annotation is MLNUserLocation {
			return nil
		}
		if let ann = annotation as? PlaceAnnotation {
			if let place = places.first(where: { $0.id?.uuidString ?? "" == ann.id }) {
				if let thumb = place.thumb {
					let annotationV = PlaceThumAnnotationView(image: thumb, size: CGSize(width: 60, height: 60))
					return annotationV
				}
			}
		}
		return nil
	}
	
	func mapView(_ mapView: MLNMapView, regionDidChangeAnimated animated: Bool) {
		if !isRunDefaultBound {
			isRunDefaultBound = true
			boundCoordinates(markerCoordinates)
		}
	}
	
	func mapView(_ mapView: MLNMapView, lineWidthForPolylineAnnotation annotation: MLNPolyline) -> CGFloat {
		return 6
	}
}
