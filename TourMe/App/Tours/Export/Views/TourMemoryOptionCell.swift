//
//  TourMemoryOptionCell.swift
//  TourMe
//
//  Created by Savet on 26/5/26.
//

import UIKit

final class TourMemoryOptionCell: UITableViewCell, CellID {

	private lazy var iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.tintColor = .label
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.medium)
		label.textColor = .label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var detailLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.medium)
		label.textColor = .label
		label.textAlignment = .right
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .default
		accessoryType = .disclosureIndicator

		contentView.addSubview(iconImageView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(detailLabel)

		NSLayoutConstraint.activate([
			iconImageView.widthAnchor.constraint(equalToConstant: 25),
			iconImageView.heightAnchor.constraint(equalToConstant: 25),
			iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),

			titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

			detailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
			detailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with item: MemoryItem) {
		titleLabel.text = item.title
		detailLabel.text = item.detail
		iconImageView.image = item.icon
	}
}
