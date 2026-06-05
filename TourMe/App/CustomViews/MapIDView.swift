//
//  MapIDView.swift
//  TourMe
//
//  Created by Savet on 5/6/26.
//

import UIKit

class MapIDView: UIView {
	
	private lazy var iconImgV: UIImageView = {
		let view = UIImageView()
		view.contentMode = .scaleAspectFit
		view.tintColor = .white
		view.image = UIImage(named: "company")
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .defaultMedium(size: 20)
		label.text = "Tour Me"
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	init() {
		super.init(frame: .zero)
		backgroundColor = UIColor(hexString: "EBEBEB")
		addSubview(iconImgV)
		addSubview(titleLabel)
		NSLayoutConstraint.activate([
			iconImgV.widthAnchor.constraint(equalToConstant: 40),
			iconImgV.heightAnchor.constraint(equalToConstant: 40),
			iconImgV.topAnchor.constraint(equalTo: topAnchor),
			iconImgV.bottomAnchor.constraint(equalTo: bottomAnchor),
			iconImgV.leadingAnchor.constraint(equalTo: leadingAnchor),
			
			titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: iconImgV.trailingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
