//
//  CellID.swift
//  TourMe
//
//  Created by Savet on 1/7/25.
//

import Foundation

protocol CellID {
	static var identifier: String { get }
}

extension CellID {
	static var identifier: String {
		return String(describing: self)
	}
}
