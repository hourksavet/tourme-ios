//
//  CompletedTourPlaceCell.swift
//  TourMe
//
//  Created by Savet on 25/5/26.
//

import UIKit

final class CompletedTourPlaceCell: UITableViewCell, CellID {

	private lazy var thumbnailImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .defaultMedium(size: UIFont.medium)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var locationIconView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "mappin.and.ellipse")
		imageView.tintColor = .label
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private lazy var addressLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.normal)
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(thumbnailImageView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(locationIconView)
		contentView.addSubview(addressLabel)

		NSLayoutConstraint.activate([
			thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			thumbnailImageView.widthAnchor.constraint(equalToConstant: 84),
			thumbnailImageView.heightAnchor.constraint(equalToConstant: 56),

			titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 2),
			titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 14),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

			locationIconView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			locationIconView.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -2),
			locationIconView.widthAnchor.constraint(equalToConstant: 18),
			locationIconView.heightAnchor.constraint(equalToConstant: 18),

			addressLabel.centerYAnchor.constraint(equalTo: locationIconView.centerYAnchor),
			addressLabel.leadingAnchor.constraint(equalTo: locationIconView.trailingAnchor, constant: 8),
			addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
		])

		thumbnailImageView.layer.cornerRadius = 10
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with place: Place) {
		thumbnailImageView.image = place.thumb.flatMap(UIImage.init(data:))
		titleLabel.text = place.name
		addressLabel.text = place.address ?? ""
	}
}
