//
//  RoundButton.swift
//  TourMe
//
//  Created by Savet on 30/6/25.
//

import UIKit

class RoundButton: UIButton {

	// MARK: - Properties
	private var shadowLayer: CAShapeLayer?
	private var radius: CGFloat!
	private var activeColor: UIColor!
	private var inactiveColor: UIColor!
	
	override var isEnabled: Bool {
		didSet {
			updateButton()
		}
	}
	
	init(radius: CGFloat = 5, activeColor: UIColor, inactiveColor: UIColor) {
		super.init(frame: .zero)
		self.radius = radius
		self.activeColor = activeColor
		self.inactiveColor = inactiveColor
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		backgroundColor = .clear
		if shadowLayer == nil {
			shadowLayer = CAShapeLayer()
			shadowLayer!.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
			shadowLayer!.fillColor = isEnabled ? activeColor.cgColor : inactiveColor.cgColor
			
			shadowLayer!.shadowColor = isEnabled ? UIColor.lightGray.cgColor : UIColor.clear.cgColor
			shadowLayer!.shadowPath = shadowLayer!.path
			shadowLayer!.shadowOffset = CGSize(width: 0.0, height: isEnabled ? 2.0 : 0.0)
			shadowLayer!.shadowOpacity = 0.5
			shadowLayer!.shadowRadius = 2
			
			layer.insertSublayer(shadowLayer!, at: 0)
		}
	}
	
	private func updateButton() {
		super.isEnabled = isEnabled
		shadowLayer?.fillColor = isEnabled ? activeColor.cgColor : inactiveColor.cgColor
		shadowLayer?.shadowOffset = CGSize(width: 0.0, height: isEnabled ? 2.0 : 0.0)
		shadowLayer?.shadowColor = isEnabled ? UIColor.lightGray.cgColor : UIColor.clear.cgColor
	}

}
