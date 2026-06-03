//
//  CompletedTourSummaryCell.swift
//  TourMe
//
//  Created by Savet on 25/5/26.
//

import UIKit

final class CompletedTourSummaryCell: UITableViewCell, CellID {

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .defaultMedium(size: UIFont.medium)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var distanceLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.medium)
		label.textAlignment = .right
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(titleLabel)
		contentView.addSubview(distanceLabel)
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			distanceLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
			distanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			distanceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(title: String, distance: String) {
		titleLabel.text = title
		distanceLabel.text = distance
	}
}
