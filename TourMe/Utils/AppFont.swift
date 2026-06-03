//
//  AppFont.swift
//  PassApp
//
//  Created by Savet on 11/5/19.
//  Copyright © 2019 PassApp Technologies Co., Ltd. All rights reserved.
//

import UIKit.UIFont

extension UIFont {
	static let tiny: CGFloat = 12
	static let small: CGFloat = 15
	static let normal: CGFloat = 17
	static let medium: CGFloat = 18
	static let larg: CGFloat = 20
	static let heading: CGFloat = 22
	
	static func defaultItalic(size: CGFloat) -> UIFont {
		return .italicSystemFont(ofSize: size)
	}
	
	static func defaultThin(size: CGFloat) -> UIFont {
		return .systemFont(ofSize: size, weight: .thin).rounded
	}
	
	static func `default`(size: CGFloat) -> UIFont {
		return .systemFont(ofSize: size, weight: .regular).rounded
	}
	
	static func defaultMedium(size: CGFloat) -> UIFont {
		return .systemFont(ofSize: size, weight: .medium).rounded
	}
	
	static func defaultSemibold(size: CGFloat) -> UIFont {
		return .systemFont(ofSize: size, weight: .semibold).rounded
	}
	
	static func defaultBold(size: CGFloat) -> UIFont {
		return .systemFont(ofSize: size, weight: .bold).rounded
	}
	
	static func defaultHeavy(size: CGFloat) -> UIFont {
		return .systemFont(ofSize: size, weight: .heavy).rounded
	}
}

extension UIFont {
	var rounded: UIFont {
		if #available(iOS 13.0, *) {
			if let descriptor = fontDescriptor.withDesign(.rounded) {
				return UIFont(descriptor: descriptor, size: pointSize)
			}
		} else {
			// Fallback on earlier versions
		}
		return self
	}
}
