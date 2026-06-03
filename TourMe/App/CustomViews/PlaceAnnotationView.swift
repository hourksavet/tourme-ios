//
//  PlaceAnnotationView.swift
//  TourMe
//
//  Created by Savet on 15/9/25.
//

import MapLibre

class PlaceAnnotationView: MLNAnnotationView {
	
	private var imageView: UIImageView!
	
	init(image: UIImage, size: CGSize, bottom: CGFloat = 0) {
		super.init(frame: .zero)

		frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height + bottom)) // size of your marker
		backgroundColor = .clear

		imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
		imageView.contentMode = .scaleAspectFit
		imageView.image = image // your custom image
		addSubview(imageView)
		
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}



