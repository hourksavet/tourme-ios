//
//  Utils.swift
//  TourMe
//
//  Created by Savet on 11/7/25.
//

import Foundation

class Utils {
	
	class func observerName(_ notify: Notify) -> NSNotification.Name {
		return NSNotification.Name(rawValue: notify.rawValue)
	}
	
	class func toDistance(meters: Int) -> String {
		var m = meters
		if m < 0 {
			m = m * (-1)
		}
		if m < 1000 {
			return "\(m) \("m".localized())"
		}
		return "\((Double(m)/1000.0).formate2f()) \("km".localized())"
	}
	
	class func toTime( _ seconds: Int) -> String {
		var sec = seconds
		if seconds <= 0 {
			sec = seconds*(-1)
		}
		if sec == 0 {
			return "0\("s".localized())"
		}
		var time = ""
		var min = sec / 60
		var h = min / 60
		min = min % 60
		sec = sec % 60
		if h > 0 {
			var day = 0
			if h >= 24 {
				day = h / 24
				h = h % 24
			}
			if day > 0 {
				time = "\(day)\("day".localized())"
				time = "\(time)\(h)\("h".localized())"
				return time
			}
			time = "\(time)\(h)\("h".localized())"
		}
		if min > 0 {
			time = "\(time)\(min)\("min".localized()) "
		}
		if sec > 0 {
			time = "\(time)\(sec)\("s".localized())"
		}
		return time
	}
}

