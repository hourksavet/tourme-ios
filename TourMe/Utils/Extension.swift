//
//  Extension.swift
//  TourMe
//
//  Created by Savet on 26/6/25.
//

import Foundation
import UIKit
import CoreLocation
import MapLibre

enum Notify: String {
	case deletePlace = "DeletePlace"
	case addPlace = "AddPlace"
	case addTour = "AddTour"
	case deleteTour = "DeleteTour"
	case updateTour = "UpdateTour"
	case statedTour = "StatedTour"
	case progressTourUpdate = "ProgressTourUpdate"
	case endedTour = "EndedTour"
}

// MARK: - Bundle
extension Bundle {
	var releaseVersion: String? {
		return infoDictionary?["CFBundleShortVersionString"] as? String
	}
	
	var codeBuildNumber: String? {
		return infoDictionary?["CFBundleVersion"] as? String
	}
}

extension Double {
	func fractionDigits(places: Int) -> Double {
		let divisor = pow(10.0, Double(places))
		return (self * divisor).rounded() / divisor
	}
	
	func formate2f() -> String {
		let numberFormatter = NumberFormatter()
		numberFormatter.locale = Locale(identifier: "en_US")
		numberFormatter.groupingSeparator = ","
		numberFormatter.numberStyle = .decimal
		var formattedNumber = numberFormatter.string(from: NSNumber(value:self))
		if let bool = formattedNumber?.contains(".") {
			if bool {
				if let range: Range<String.Index> = formattedNumber!.range(of: ".") {
					let index: Int = formattedNumber!.distance(from: formattedNumber!.startIndex, to: range.lowerBound)
					if index + 3 != formattedNumber?.count  {
						if formattedNumber?.count ?? 0 < index + 3 {
							formattedNumber = "\(formattedNumber ?? "")0"
						}else {
							let ix = formattedNumber!.index(formattedNumber!.startIndex, offsetBy: index + 3)
							let str = formattedNumber![..<ix]
							formattedNumber = "\(str)"
						}
					}
				}
			}else {
				formattedNumber = "\(formattedNumber ?? "").00"
			}
		}
		return formattedNumber ?? "\(self)"
	}
}

extension String {
	
	static let place = "Place"
	static let tour = "Tour"
	
	func localized() -> String {
		let lang = Variable.shared.languageKey
		let path = Bundle.main.path(forResource: lang, ofType: "lproj")
		let bundle = Bundle(path: path!)
		return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
	}
}

// MARK: - NSAttributedString
extension NSAttributedString {
	
	func paragraphStyleWithLine(string: String, line: CGFloat) -> NSAttributedString {
		let attributedString = NSMutableAttributedString(string: string)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = line
		attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
		return attributedString
	}
	
	func multiStyles(lineSpace: CGFloat, resources: [Dictionary<UIFont, UIColor>], texts: [String]) -> NSAttributedString {
		if resources.count != texts.count {
			return self
		}
		let style = NSMutableParagraphStyle()
		let para = NSMutableAttributedString()
		style.lineSpacing = lineSpace
		
		for i in 0 ... resources.count - 1 {
			var font: UIFont!
			for f in resources[i].keys {
				font = f
				break
			}
			var color: UIColor!
			for c in resources[i].values {
				color = c
				break
			}
			let attributes = [NSAttributedString.Key.font: font ?? UIFont.default(size: 12), NSAttributedString.Key.foregroundColor: color ?? UIColor.primary] as [NSAttributedString.Key : Any]
			let attrString = NSAttributedString(string: texts[i], attributes: attributes)
			para.append(attrString)
		}
		para.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0,length: para.length))
		return para
	}
	
	/// Returns a new instance of NSAttributedString with same contents and attributes with strike through added.
	/// - Parameter style: value for style you wish to assign to the text.
	/// - Returns: a new instance of NSAttributedString with given strike through.
	func withStrikeThrough(_ style: Double = 1) -> NSAttributedString {
		let attributedString = NSMutableAttributedString(attributedString: self)
		attributedString.addAttribute(.strikethroughStyle, value: style, range: NSRange(location: 0, length: string.count))
		return NSAttributedString(attributedString: attributedString)
	}
}


extension UIViewController {
	
	func showToast(message:String) {
		let toastLabel = PaddingLabel(padding: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
		toastLabel.translatesAutoresizingMaskIntoConstraints = false
		toastLabel.backgroundColor = .darkGray
		toastLabel.textColor = .white
		
		toastLabel.textAlignment = .center;
		toastLabel.font = .default(size: 15)
		toastLabel.text = message
		toastLabel.cornerRadius(6)
		
		view.addSubview(toastLabel)
		toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
		toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		toastLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 30).isActive = true
		toastLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -30).isActive = true
		UIView.animate(withDuration: 3.0, delay: 0, options: .curveEaseOut, animations: {
			toastLabel.alpha = 0.9
		}, completion: { (isCompleted) in
			toastLabel.removeFromSuperview()
		})
	}
	
	@objc open func toNavigationController() -> UINavigationController {
		let nv = UINavigationController(rootViewController: self)
//		nv.navigationBar.setBackgroundImage(UIImage(), for: .defaultPrompt)
//		nv.navigationBar.shadowImage = nil
//		let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
//		nv.navigationBar.titleTextAttributes = textAttributes
		return nv
	}
	
}

extension UIView {
	
	func cornerRadius(_ corner: CGFloat = 0) {
		self.layer.cornerRadius = corner == 0 ? self.frame.height/2 : corner
		self.contentMode = .scaleAspectFill
		self.clipsToBounds = true
	}
	
	func addShadow(radius: CGFloat) {
		layer.cornerRadius = radius
		layer.masksToBounds = false
		layer.shadowColor = UIColor(hexString: "535353").cgColor
		layer.shadowOffset = CGSize(width: 0, height: 1)
		layer.shadowOpacity = 0.3
		layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
	}
	
	func addGradient(colors: [UIColor]) {
		layer.sublayers?.forEach { $0.removeFromSuperlayer() }
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = bounds
		gradientLayer.colors = colors
		gradientLayer.locations = [0.0, 2.0]
		layer.insertSublayer(gradientLayer, at: 0)
	}
	
	func roundCorners(corners: UIRectCorner, radius: CGFloat, strokeColor: UIColor) {
		layer.sublayers?.forEach { $0.removeFromSuperlayer() }
		let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.lineWidth = 2
		mask.path = path.cgPath
		mask.position.y = mask.position.y - 2
		mask.strokeColor = strokeColor.cgColor
		mask.fillColor = strokeColor.cgColor
		self.layer.addSublayer(mask)
	}
}

// MARK: - UITableViewCell
extension UITableView {
	
	// Header/Footer View
	
	final func register<View: UITableViewHeaderFooterView>(_ viewClass: View.Type) {
		register(viewClass, forHeaderFooterViewReuseIdentifier: String(describing: viewClass))
	}
	
	final func unregister<View: UITableViewHeaderFooterView>(_ viewClass: View.Type) {
		register(nil as AnyClass?, forHeaderFooterViewReuseIdentifier: String(describing: viewClass))
	}
	
	final func dequeue<View: UITableViewHeaderFooterView>(_ viewClass: View.Type) -> View {
		return dequeueReusableHeaderFooterView(withIdentifier: String(describing: viewClass)) as! View
	}
	
	// Cell
	
	final func register<Cell: UITableViewCell>(_ cellClass: Cell.Type) {
		register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
	}
	
	final func register<Cell: UITableViewCell>(_ cellClass: Cell.Type, identifier: String) {
		register(cellClass, forCellReuseIdentifier: identifier)
	}
	
	final func unregister<Cell: UITableViewCell>(_ cellClass: Cell.Type) {
		register(nil as AnyClass?, forCellReuseIdentifier: String(describing: cellClass))
	}
	
	final func dequeue<Cell: UITableViewCell>(_ cellClass: Cell.Type, for indexPath: IndexPath) -> Cell {
		return dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath) as! Cell
	}
	
	final func dequeue<Cell: UITableViewCell>(_ cellClass: Cell.Type, identifier: String, for indexPath: IndexPath) -> Cell {
		return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! Cell
	}
	
}

extension UIImage {
	convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 32)) {
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.setFill()
		UIRectFill(CGRect(origin: .zero, size: size))
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		self.init(cgImage: image.cgImage!)
	}
	
	func resizeImage(maxSize: CGFloat) -> UIImage {
		if max(size.width, size.height) > maxSize {
			let widthRatio  = maxSize  / size.width
			let heightRatio = maxSize / size.height
			let ratio = widthRatio > heightRatio ? heightRatio : widthRatio
			let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
			let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
			UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
			draw(in: rect)
			let newImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			if let safeImage = newImage {
				return safeImage
			}
		}
		return self
	}
	
	func compressImage(toMaxKB: Int) -> Data {
		var quality : CGFloat = 1
		var resizeImageData = self.jpegData(compressionQuality: quality)!
		var imageSizeKB = resizeImageData.count / 1024
		while imageSizeKB > toMaxKB {
			quality -= 0.01
			resizeImageData = self.jpegData(compressionQuality: quality)!
			imageSizeKB = resizeImageData.count / 1024
		}
		return resizeImageData
	}
}

extension ToureMeMapView {
	
	func addPolyline(coordinates: [CLLocationCoordinate2D], sourceID: String, layerID: String, color: UIColor, width: CGFloat, dash: Int? = nil, gap: Int? = nil) {
		
		let polyline = MLNPolyline(coordinates: coordinates, count: UInt(coordinates.count))

		let source = MLNShapeSource(identifier: sourceID, shape: polyline, options: nil)
		let layer = MLNLineStyleLayer(identifier: layerID, source: source)
		
		layer.lineColor = NSExpression(forConstantValue: color)
		layer.lineWidth = NSExpression(forConstantValue: width)
		if let dash = dash, let gap = gap {
			layer.lineDashPattern = NSExpression(forConstantValue: [NSNumber(value: dash), NSNumber(value: gap)])
		}
		if let style = style {
			// Remove old route
			if let oldSource = style.source(withIdentifier: sourceID),
				let oldLayer = style.layer(withIdentifier: layerID) {
				style.removeLayer(oldLayer)
				style.removeSource(oldSource)
			}
			style.addSource(source)
			style.addLayer(layer)
		}
	}
	
	func removePolyline(sourceID: String, layerID: String) {
		if let style = style {
			if let oldSource = style.source(withIdentifier: sourceID),
				let oldLayer = style.layer(withIdentifier: layerID) {
				style.removeLayer(oldLayer)
				style.removeSource(oldSource)
			}
		}
	}
	
	func addAnnotation(_ annotation: PlaceAnnotation) {
		removeAnnotation(id: annotation.id )
		super.addAnnotation(annotation)
	}
	
	func removeAnnotation(id: String) {
		if let annos = annotations {
			for anno in annos {
				if let pointAnno = anno as? PlaceAnnotation {
					if pointAnno.id == id {
						removeAnnotation(pointAnno)
						break
					}
				}
			}
		}
	}
}
