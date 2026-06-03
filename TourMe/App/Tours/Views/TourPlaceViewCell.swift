//
//  TourPlaceViewCell.swift
//  TourMe
//
//  Created by Savet on 15/7/25.
//

import UIKit

class TourPlaceViewCell: UITableViewCell {

	private var place: Place!
	
	private lazy var thumbnailImgV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFill
		imgV.translatesAutoresizingMaskIntoConstraints = false
		return imgV
	}()
	
	private lazy var nameLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .defaultMedium(size: UIFont.normal)
		return label
	}()
	
	private lazy var visitLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .default(size: UIFont.small)
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(thumbnailImgV)
		contentView.addSubview(nameLabel)
		contentView.addSubview(visitLabel)
		
		NSLayoutConstraint.activate([
			thumbnailImgV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			thumbnailImgV.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			thumbnailImgV.widthAnchor.constraint(equalToConstant: 90),
			thumbnailImgV.heightAnchor.constraint(equalToConstant: 60),
			nameLabel.leadingAnchor.constraint(equalTo: thumbnailImgV.trailingAnchor, constant: 10),
			nameLabel.bottomAnchor.constraint(equalTo: thumbnailImgV.centerYAnchor, constant: -3),
			visitLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
			visitLabel.topAnchor.constraint(equalTo: thumbnailImgV.centerYAnchor, constant: 4),
		])
		thumbnailImgV.cornerRadius(10)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(with place: Place) {
		self.place = place
		thumbnailImgV.image = UIImage(data: place.thumb ?? Data())
		nameLabel.text = place.name
		visitLabel.text = "\(place.visitCount) \("visit".localized())"
	}

}
