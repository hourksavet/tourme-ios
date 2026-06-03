//
//  PlaceThumAnnotationView.swift
//  TourMe
//
//  Created by Savet on 20/11/25.
//

import MapLibre

class PlaceThumAnnotationView: MLNAnnotationView {
	
	private var placeThumImgV: UIImageView!
	private var annotationImgV: UIImageView!
	
	init(image: Data, size: CGSize) {
		super.init(frame: .zero)

		frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height * 2)) // size of your marker
		backgroundColor = .clear

		let annotationImage = UIImage(named: "ic_place_marker")!.withRenderingMode(.automatic).withTintColor(.red)
		annotationImgV = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
		annotationImgV.contentMode = .scaleAspectFit
		annotationImgV.image = annotationImage
		addSubview(annotationImgV)
		
		placeThumImgV = UIImageView(image: UIImage(data: image))
		placeThumImgV.clipsToBounds = true
		placeThumImgV.translatesAutoresizingMaskIntoConstraints = false
		annotationImgV.addSubview(placeThumImgV)
		NSLayoutConstraint.activate([
			placeThumImgV.topAnchor.constraint(equalTo: annotationImgV.topAnchor, constant: 7),
			placeThumImgV.leadingAnchor.constraint(equalTo: annotationImgV.leadingAnchor, constant: 15),
			placeThumImgV.trailingAnchor.constraint(equalTo: annotationImgV.trailingAnchor, constant: -15),
			placeThumImgV.heightAnchor.constraint(equalTo: placeThumImgV.widthAnchor)
		])
		
		let pointV = UIView()
		pointV.backgroundColor = .red
		pointV.translatesAutoresizingMaskIntoConstraints = false
		addSubview(pointV)
		NSLayoutConstraint.activate([
			pointV.centerXAnchor.constraint(equalTo: centerXAnchor),
			pointV.centerYAnchor.constraint(equalTo: centerYAnchor),
			pointV.widthAnchor.constraint(equalToConstant: 6),
			pointV.heightAnchor.constraint(equalToConstant: 6)
		])
		pointV.cornerRadius(3)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		placeThumImgV.cornerRadius()
	}
}
