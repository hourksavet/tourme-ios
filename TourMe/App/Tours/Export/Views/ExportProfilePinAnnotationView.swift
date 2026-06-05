//
//  ExportProfilePinAnnotationView.swift
//  TourMe
//
//  Created by Savet on 5/6/26.
//

import UIKit
import MapLibre

final class ExportProfilePinAnnotationView: MLNAnnotationView {

	private let profileImageView: UIImageView
	private let carImgV: UIImageView

	init(image: UIImage, size: CGSize, carRotation: CGFloat) {
		profileImageView = UIImageView(image: image)
		carImgV = UIImageView()
		super.init(frame: CGRect(origin: .zero, size: size))
		backgroundColor = .clear
		carImgV.image = UIImage(named: "car-top-view")
		carImgV.contentMode = .scaleAspectFit
		carImgV.clipsToBounds = true
		carImgV.translatesAutoresizingMaskIntoConstraints = false
		carImgV.layer.shadowColor = UIColor.black.withAlphaComponent(0.14).cgColor
		carImgV.layer.shadowOpacity = 1
		carImgV.layer.shadowOffset = CGSize(width: 0, height: 3)
		carImgV.layer.shadowRadius = 10
		carImgV.transform = CGAffineTransform(rotationAngle: carRotation)
		addSubview(carImgV)
		

		profileImageView.contentMode = .scaleAspectFill
		profileImageView.clipsToBounds = true
		profileImageView.translatesAutoresizingMaskIntoConstraints = false
		profileImageView.layer.shadowColor = UIColor.black.withAlphaComponent(0.14).cgColor
		profileImageView.layer.shadowOpacity = 1
		profileImageView.layer.borderWidth = 3
		profileImageView.layer.borderColor = UIColor.white.cgColor
		profileImageView.layer.shadowOffset = CGSize(width: 0, height: 3)
		profileImageView.layer.shadowRadius = 10
		addSubview(profileImageView)

		NSLayoutConstraint.activate([
			carImgV.widthAnchor.constraint(equalToConstant: 60),
			carImgV.heightAnchor.constraint(equalToConstant: 60),
			carImgV.centerXAnchor.constraint(equalTo: centerXAnchor),
			carImgV.centerYAnchor.constraint(equalTo: centerYAnchor),
			
			profileImageView.widthAnchor.constraint(equalToConstant: 90),
			profileImageView.heightAnchor.constraint(equalToConstant: 90),
			profileImageView.bottomAnchor.constraint(equalTo: carImgV.centerYAnchor),
			profileImageView.centerXAnchor.constraint(equalTo: carImgV.centerXAnchor),
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func updateCarRotation(_ rotation: CGFloat) {
		carImgV.transform = CGAffineTransform(rotationAngle: rotation)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
	}
}

