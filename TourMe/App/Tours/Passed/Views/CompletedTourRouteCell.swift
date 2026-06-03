//
//  CompletedTourRouteCell.swift
//  TourMe
//
//  Created by Savet on 25/5/26.
//

import UIKit
import MapLibre

final class CompletedTourRouteCell: UITableViewCell, CellID {

	private lazy var mapView: ToureMeMapView = {
		let map = ToureMeMapView()
		map.isRotateEnabled = false
		map.showsUserLocation = false
		map.translatesAutoresizingMaskIntoConstraints = false
		return map
	}()

	private lazy var distanceIconView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "ic_route_distance") ?? UIImage(systemName: "point.topleft.down.curvedto.point.bottomright.scurvepath")
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private lazy var distanceLabel: UILabel = {
		let label = UILabel()
		label.font = .defaultMedium(size: UIFont.medium)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var durationIconView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "hourglass")
		imageView.tintColor = .label
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private lazy var durationLabel: UILabel = {
		let label = UILabel()
		label.font = .defaultMedium(size: UIFont.medium)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private var visitPlaces: [VisitPlace] = []
	private var renderedRouteIDs: [(String, String)] = []
	private var renderVersion: Int = 0

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(mapView)
		contentView.addSubview(distanceIconView)
		contentView.addSubview(distanceLabel)
		contentView.addSubview(durationIconView)
		contentView.addSubview(durationLabel)

		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: contentView.topAnchor),
			mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			mapView.heightAnchor.constraint(equalToConstant: 360),

			distanceIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
			distanceIconView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 14),
			distanceIconView.widthAnchor.constraint(equalToConstant: 20),
			distanceIconView.heightAnchor.constraint(equalToConstant: 20),

			distanceLabel.centerYAnchor.constraint(equalTo: distanceIconView.centerYAnchor),
			distanceLabel.leadingAnchor.constraint(equalTo: distanceIconView.trailingAnchor, constant: 10),

			durationIconView.leadingAnchor.constraint(equalTo: distanceLabel.trailingAnchor, constant: 40),
			durationIconView.centerYAnchor.constraint(equalTo: distanceIconView.centerYAnchor),
			durationIconView.widthAnchor.constraint(equalToConstant: 18),
			durationIconView.heightAnchor.constraint(equalToConstant: 18),

			durationLabel.centerYAnchor.constraint(equalTo: durationIconView.centerYAnchor),
			durationLabel.leadingAnchor.constraint(equalTo: durationIconView.trailingAnchor, constant: 10),
			durationLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8),
			durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
		])

		mapView.delegate = self
		mapView.layer.cornerRadius = 15
		backgroundColor = .clear
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		clearMapContent()
	}

	func configure(visitPlaces: [VisitPlace], distanceText: String, durationText: String) {
		self.visitPlaces = visitPlaces
		distanceLabel.text = distanceText
		durationLabel.text = durationText
		renderVersion += 1
		renderMap(for: visitPlaces, version: renderVersion)
	}

	private func renderMap(for visitPlaces: [VisitPlace], version: Int) {
		clearMapContent()
		let places = visitPlaces.compactMap(\ .place)
		let coordinates = places.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng) }
		guard !coordinates.isEmpty else { return }

		for place in places {
			let annotation = PlaceAnnotation()
			annotation.id = place.id?.uuidString ?? UUID().uuidString
			annotation.coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
			annotation.title = place.name
			mapView.addAnnotation(annotation)
		}

		guard coordinates.count > 1 else {
			boundCoordinates(coordinates)
			return
		}

		DispatchQueue.global(qos: .userInitiated).async {
			var segments: [([CLLocationCoordinate2D], String, String)] = []
			for index in 1..<coordinates.count {
				let routeCoordinates = Const.routingProvider.coordinates(coordinates[index - 1], coordinates[index])
				if !routeCoordinates.isEmpty {
					segments.append((routeCoordinates, "completed_route_source_\(index)", "completed_route_layer_\(index)"))
				}
			}

			DispatchQueue.main.async { [weak self] in
				guard let self, self.renderVersion == version else { return }
				for segment in segments {
					self.mapView.addPolyline(coordinates: segment.0, sourceID: segment.1, layerID: segment.2, color: .primary, width: 4)
				}
				self.renderedRouteIDs = segments.map { ($0.1, $0.2) }
				self.boundCoordinates(coordinates)
			}
		}
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
}

extension CompletedTourRouteCell: MLNMapViewDelegate {

	func mapView(_ mapView: MLNMapView, viewFor annotation: any MLNAnnotation) -> MLNAnnotationView? {
		if annotation is MLNUserLocation {
			return nil
		}

		guard let placeAnnotation = annotation as? PlaceAnnotation,
			  let place = visitPlaces.compactMap(\ .place).first(where: { $0.id?.uuidString == placeAnnotation.id }) else {
			return nil
		}

		if let thumb = place.thumb {
			return PlaceThumAnnotationView(image: thumb, size: CGSize(width: 56, height: 56))
		}
		let markerImage = UIImage(named: "ic_place_marker") ?? UIImage(systemName: "mappin")!
		return PlaceAnnotationView(image: markerImage, size: CGSize(width: 36, height: 36), bottom: 8)
	}

	func mapViewDidFinishLoadingMap(_ mapView: MLNMapView) {
		renderVersion += 1
		renderMap(for: visitPlaces, version: renderVersion)
	}
}
