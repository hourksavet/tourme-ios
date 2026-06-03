//
//  VisitPlace.swift
//  TourMe
//
//  Created by Savet on 27/11/25.
//

enum VisitPlaceStatus: String {
	case waiting = "WAITING"
	case onging = "ONGOING"
	case arrived = "ARRIVED" // or visiting
	case visited = "VISITED"
}

extension VisitPlace {
	var status: VisitPlaceStatus {
		get {
			return VisitPlaceStatus(rawValue: self.status_code ?? "WAITING") ?? .waiting
		}
	}
}
