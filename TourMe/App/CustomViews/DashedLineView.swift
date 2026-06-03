//
//  DashedLineView.swift
//  TourMe
//
//  Created by Savet on 23/7/25.
//

import UIKit

class DashedLineView: UIView {

	private var isDashed: Bool = false
	
	override func layoutSubviews() {
		super.layoutSubviews()
		if !isDashed {
			isDashed = true
			createDashedLine()
		}
	}

	private func createDashedLine() {
		self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

		let shapeLayer = CAShapeLayer()
		shapeLayer.strokeColor = UIColor.primary.cgColor
		shapeLayer.lineWidth = 2
		shapeLayer.lineDashPattern = [6, 3]  // 6pt dash, 3pt gap

		let path = CGMutablePath()
		path.addLines(between: [CGPoint(x: 0, y: bounds.midY), CGPoint(x: bounds.width, y: bounds.midY)])
		shapeLayer.path = path
		layer.addSublayer(shapeLayer)
	}

}
