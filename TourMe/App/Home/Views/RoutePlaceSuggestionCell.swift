//
//  RoutePlaceSuggestionCell.swift
//  TourMe
//
//  Created by Savet on 3/6/26.
//

import UIKit

final class RoutePlaceSuggestionCell: UITableViewCell, CellID {

	private lazy var thumbnailImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .defaultMedium(size: 17)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: 15)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(thumbnailImageView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(subtitleLabel)

		NSLayoutConstraint.activate([
			thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
			thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			thumbnailImageView.widthAnchor.constraint(equalToConstant: 86),
			thumbnailImageView.heightAnchor.constraint(equalToConstant: 56),

			titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 14),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -3),

			subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
			subtitleLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 3)
		])

		thumbnailImageView.cornerRadius(12)
		selectionStyle = .none
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with placeModel: PlaceListModel) {
		thumbnailImageView.image = UIImage(data: placeModel.place.thumb ?? Data())
		titleLabel.text = placeModel.place.name
		let visitCount = Int(placeModel.place.visitCount)
		if visitCount <= 0 {
			subtitleLabel.text = "Never visited"
		} else if visitCount == 1 {
			subtitleLabel.text = "Visited 1 time"
		} else {
			subtitleLabel.text = "Visited \(visitCount) times"
		}
	}
}
