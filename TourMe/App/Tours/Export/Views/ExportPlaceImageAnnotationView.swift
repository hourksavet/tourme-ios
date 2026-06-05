//
//  ExportPlaceImageAnnotationView.swift
//  TourMe
//
//  Created by Savet on 5/6/26.
//

import MapLibre

final class ExportPlaceImageAnnotationView: MLNAnnotationView {

	private let imageView: UIImageView

	init(imageData: Data, size: CGSize) {
		imageView = UIImageView(image: UIImage(data: imageData))
		super.init(frame: CGRect(origin: .zero, size: size))
		backgroundColor = .clear
		imageView.frame = bounds
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 10
		imageView.layer.borderWidth = 3
		imageView.layer.borderColor = UIColor.white.cgColor
		imageView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
		imageView.layer.shadowOpacity = 0
		addSubview(imageView)
		layer.shadowColor = UIColor.black.withAlphaComponent(0.22).cgColor
		layer.shadowOpacity = 1
		layer.shadowOffset = CGSize(width: 0, height: 3)
		layer.shadowRadius = 10
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
