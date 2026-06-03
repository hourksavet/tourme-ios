//
//  ProgressTourViewCell.swift
//  TourMe
//
//  Created by Savet on 22/7/25.
//

import UIKit

class ProgressTourViewCell: UITableViewCell, CellID {

	private var tour: Tour!
	
	private lazy var thumbImageV: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFill
		imgV.clipsToBounds = true
		imgV.layer.cornerRadius = 10
		imgV.backgroundColor = .lightGray
		imgV.translatesAutoresizingMaskIntoConstraints = false
		return imgV
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .defaultMedium(size: UIFont.normal)
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var placeCountLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.normal)
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var distanceLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.normal)
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(thumbImageV)
		contentView.addSubview(titleLabel)
		contentView.addSubview(placeCountLabel)
		contentView.addSubview(distanceLabel)
		
		NSLayoutConstraint.activate([
			thumbImageV.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 15),
			thumbImageV.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
			thumbImageV.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15),
			thumbImageV.widthAnchor.constraint(equalToConstant: 90),
			thumbImageV.heightAnchor.constraint(equalToConstant: 90 * 3 / 5),
			titleLabel.leadingAnchor.constraint(equalTo: thumbImageV.trailingAnchor, constant: 15),
			titleLabel.bottomAnchor.constraint(equalTo: thumbImageV.centerYAnchor, constant: -4),
			
			placeCountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			placeCountLabel.topAnchor.constraint(equalTo: thumbImageV.centerYAnchor, constant: 4),
			distanceLabel.centerYAnchor.constraint(equalTo: placeCountLabel.centerYAnchor),
			distanceLabel.leadingAnchor.constraint(equalTo: placeCountLabel.trailingAnchor, constant: 15)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configer(_ tour: Tour) {
		self.tour = tour
		thumbImageV.image = UIImage(data: tour.banner!)
		titleLabel.text = tour.name
		placeCountLabel.text = "\(tour.visitPlaces?.count ?? 0) \("places".localized())"
		distanceLabel.text = "\(500) \("km".localized())"
	}
}
