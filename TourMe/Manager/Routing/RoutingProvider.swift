//
//  RoutingProvider.swift
//  PassApp
//
//  Created by Savet on 20/6/25.
//  Copyright © 2025 PassApp Technologies Co., Ltd. All rights reserved.
//

import Foundation
import CoreLocation

class RoutingProvider {
	
	private var routingManager: RoutingManager!
	
	init () {
		if let orderPath = Bundle.main.path(forResource: "order", ofType: ""),
		   let tailPath = Bundle.main.path(forResource: "tail", ofType: ""),
		   let headPath = Bundle.main.path(forResource: "head", ofType: ""),
		   let ttPath = Bundle.main.path(forResource: "travel_time", ofType: ""),
		   let latPath = Bundle.main.path(forResource: "latitude", ofType: ""),
		   let lngPath = Bundle.main.path(forResource: "longitude", ofType: "") {
			routingManager = RoutingManager(pathOrder: orderPath, pathTail: tailPath, pathHead: headPath, pathTT: ttPath, pathLat: latPath, pathLng: lngPath)
			routingManager.setup()
		}
	}
	
	deinit {
		print("\(self) dead!")
	}
	
	private func encodePolyline(from coordinates: [CLLocationCoordinate2D]) -> String {
		var encoded = ""
		var prevLat = 0
		var prevLng = 0

		for coord in coordinates {
			let lat = Int(round(coord.latitude * 1e5))
			let lng = Int(round(coord.longitude * 1e5))

			let deltaLat = lat - prevLat
			let deltaLng = lng - prevLng

			[deltaLat, deltaLng].forEach { value in
				var v = (value < 0) ? ~(value << 1) : value << 1
				while v >= 0x20 {
					encoded.append(Character(UnicodeScalar((0x20 | (v & 0x1f)) + 63)!))
					v >>= 5
				}
				encoded.append(Character(UnicodeScalar(v + 63)!))
			}

			prevLat = lat
			prevLng = lng
		}

		return encoded
	}
	
	func distance(_ coordinates: [CLLocationCoordinate2D]) -> Int {
		var distance: Double = 0
		if coordinates.count > 1 {
			for i in 1..<coordinates.count {
				let fromLocation = CLLocation(latitude: coordinates[i].latitude, longitude: coordinates[i].longitude)
				let toLocation = CLLocation(latitude: coordinates[i - 1].latitude, longitude: coordinates[i - 1].longitude)
				distance += fromLocation.distance(from: toLocation)
			}
		}
		return Int(distance)
	}
	
	func coordinates(_ fromCoor: CLLocationCoordinate2D, _ toCoor: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
		var coordinates: [CLLocationCoordinate2D] = []
		if let result = routingManager?.coordinates(
			fromLat: fromCoor.latitude,
			fromLng: fromCoor.longitude,
			toLat: toCoor.latitude,
			toLng: toCoor.longitude
		) {
			let array = result.map { dict in
				Dictionary(uniqueKeysWithValues:
					dict.compactMap { key, value in
					(key as? String).map { ($0, value as! Double) }
					}
				)
			}
			for location in array {
				if let lat = location["lat"], let lng = location["lng"] {
					let coor = CLLocationCoordinate2D(latitude: lat, longitude: lng)
					coordinates.append(coor)
				}
			}
		}
		return coordinates
	}
	
	func travelDuration(_ fromCoor: CLLocationCoordinate2D, _ toCoor: CLLocationCoordinate2D) -> Int {
		
		if let result = routingManager?.travelDuration(
			fromLat: fromCoor.latitude,
			fromLng: fromCoor.longitude,
			toLat: toCoor.latitude,
			toLng: toCoor.longitude
		) {
			return result
		}
		return 0
	}
	
	func polyline(_ fromCoor: CLLocationCoordinate2D, _ toCoor: CLLocationCoordinate2D) -> (polyline: String, distance: Int, duration: Int) {
		let coordinates = coordinates(fromCoor, toCoor)
		let duration: Int = travelDuration(fromCoor, toCoor)
		let encoded = encodePolyline(from: coordinates)
		let distance = distance(coordinates)
		return (encoded, distance, duration)
	}
}
