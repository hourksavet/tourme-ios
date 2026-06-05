//
//  ExportProfilePinAnnotationView.swift
//  TourMe
//
//  Created by Savet on 5/6/26.
//

import MapLibre

final class ExportProfilePinAnnotationView: MLNAnnotationView {

	private let bubbleView = UIView()
	private let profileImageView: UIImageView
	private let pointerView = UIView()

	init(image: UIImage, size: CGSize) {
		profileImageView = UIImageView(image: image)
		super.init(frame: CGRect(origin: .zero, size: size))
		backgroundColor = .clear

		bubbleView.backgroundColor = .white
		bubbleView.translatesAutoresizingMaskIntoConstraints = false
		bubbleView.layer.shadowColor = UIColor.black.withAlphaComponent(0.18).cgColor
		bubbleView.layer.shadowOpacity = 1
		bubbleView.layer.shadowOffset = CGSize(width: 0, height: 4)
		bubbleView.layer.shadowRadius = 10
		addSubview(bubbleView)

		profileImageView.contentMode = .scaleAspectFill
		profileImageView.clipsToBounds = true
		profileImageView.translatesAutoresizingMaskIntoConstraints = false
		bubbleView.addSubview(profileImageView)

		pointerView.backgroundColor = .white
		pointerView.translatesAutoresizingMaskIntoConstraints = false
		pointerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.14).cgColor
		pointerView.layer.shadowOpacity = 1
		pointerView.layer.shadowOffset = CGSize(width: 0, height: 3)
		pointerView.layer.shadowRadius = 6
		addSubview(pointerView)

		NSLayoutConstraint.activate([
			bubbleView.topAnchor.constraint(equalTo: topAnchor),
			bubbleView.centerXAnchor.constraint(equalTo: centerXAnchor),
			bubbleView.widthAnchor.constraint(equalToConstant: size.width),
			bubbleView.heightAnchor.constraint(equalToConstant: size.width),

			profileImageView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
			profileImageView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
			profileImageView.widthAnchor.constraint(equalToConstant: size.width - 28),
			profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),

			pointerView.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
			pointerView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
			pointerView.widthAnchor.constraint(equalToConstant: 28),
			pointerView.heightAnchor.constraint(equalToConstant: 28)
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		bubbleView.layer.cornerRadius = bubbleView.bounds.width / 2
		profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
		pointerView.transform = CGAffineTransform(rotationAngle: .pi / 4)
		pointerView.layer.cornerRadius = 6
	}
}

