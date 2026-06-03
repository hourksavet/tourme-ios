//
//  AppColor.swift
//  PassApp
//
//  Created by Savet on 11/5/19.
//  Copyright © 2019 PassApp Technologies Co., Ltd. All rights reserved.
//

import UIKit.UIColor
import CoreGraphics

extension UIColor {
	
	static var random: UIColor {
		return UIColor(
			red: CGFloat.random(in: 0...1),
			green: CGFloat.random(in: 0...1),
			blue: CGFloat.random(in: 0...1),
			alpha: 1.0
		)
	}
	
	static var primary: UIColor {
		return UIColor(hexString: "77C1D6")
	}
	
	static var lightPrimary: UIColor {
		return UIColor(hexString: "CAE4ED")
	}
	
	static var darkPrimary: UIColor {
		return UIColor(hexString: "0484A8")
	}
	
	static var secondary: UIColor {
		return UIColor(hexString: "DEF8FF")
	}
	
	static var screenBackground: UIColor {
		return UIColor(hexString: "F2F2F7")
	}
	
	static var hintText: UIColor {
		return UIColor(hexString: "A5A5A5")
	}
	
	static var imageHint: UIColor {
		return UIColor(hexString: "CCCCCC")
	}
	
	convenience init(hexString: String, alpha: CGFloat? = 1) {
		let scanner = Scanner(string: hexString)
		var rgbValue: UInt64 = 0
		scanner.scanHexInt64(&rgbValue)
		
		let r = (rgbValue & 0xff0000) >> 16
		let g = (rgbValue & 0xff00) >> 8
		let b = rgbValue & 0xff
		
		self.init(
			red: CGFloat(r) / 0xff,
			green: CGFloat(g) / 0xff,
			blue: CGFloat(b) / 0xff, alpha: alpha!
		)
	}
	
}
