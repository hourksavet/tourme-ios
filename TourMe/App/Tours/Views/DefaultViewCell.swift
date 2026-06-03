//
//  DefaultViewCell.swift
//  TourMe
//
//  Created by Savet on 7/7/25.
//

import UIKit

class DefaultViewCell: UITableViewCell, CellID {

	lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .default(size: UIFont.normal)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(titleLabel)
		NSLayoutConstraint.activate([
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
